#!/bin/bash

# ファイル名の設定
GPG_FILE="passwords.txt.gpg"
PLAINTEXT_FILE="passwords.txt"

echo "================================="
echo "  パスワードマネージャーへようこそ  "
echo "================================="

while true; do
    echo ""
    echo "次の選択肢から入力してください(Add Password/Get Password/Exit):"
    read choice

    if [ "$choice" == "Add Password" ]; then
        # 1. まずサービスの情報を入力（中身）
        echo "---------------------------------"
        echo "【データの入力】保存する情報を入力してください"
        echo "---------------------------------"
        echo "サービス名を入力してください:"
        read service_name
        echo "ユーザー名を入力してください:"
        read username
        echo "パスワードを入力してください（保存データ）:"
        read password

        # 2. ここで明確に「暗号化の鍵」を聞く（金庫の鍵）
        echo ""
        echo "---------------------------------"
        echo "【セキュリティ保護】"
        echo "ファイルを暗号化して保存します。"
        echo "マスターパスワード（GPGの鍵）を入力してください:"
        echo "※画面には表示されません"
        echo "---------------------------------"
        # -s オプションで入力を隠す（セキュリティ向上！）
        read -s gpg_pass 
        echo "" 

        # --- ここから裏側の処理（ユーザーには見えない） ---

        # 既存のファイルがあるなら、一旦復号する
        if [ -f "$GPG_FILE" ]; then
            gpg --quiet --batch --yes --decrypt --passphrase="$gpg_pass" --pinentry-mode loopback "$GPG_FILE" > "$PLAINTEXT_FILE" 2> /dev/null
            
            # パスワードミスで復号できなかった場合のガード
            if [ $? -ne 0 ]; then
                echo "❌ エラー：マスターパスワードが間違っています。処理を中断します。"
                continue
            fi
        fi

        # データを追記
        echo "$service_name,$username,$password" >> "$PLAINTEXT_FILE"

        # 暗号化して保存（さっき入力したマスターパスワードを使う）
        gpg --quiet --batch --yes --symmetric --passphrase="$gpg_pass" --pinentry-mode loopback --output "$GPG_FILE" "$PLAINTEXT_FILE"

        # 生データは即削除
        rm "$PLAINTEXT_FILE"
        
        echo "✅ パスワードの追加と暗号化に成功しました！"


    elif [ "$choice" == "Get Password" ]; then
        echo "---------------------------------"
        echo "【データの検索】"
        echo "---------------------------------"
        echo "サービス名を入力してください:"
        read service_name

        # Getの時も、明確に「鍵を開けるよ」と伝える
        echo ""
        echo "---------------------------------"
        echo "【セキュリティ解除】"
        echo "暗号化ファイルを復号します。"
        echo "マスターパスワード（GPGの鍵）を入力してください:"
        echo "---------------------------------"
        read -s gpg_pass
        echo ""

        if [ -f "$GPG_FILE" ]; then
            # 復号処理
            gpg --quiet --batch --yes --decrypt --passphrase="$gpg_pass" --pinentry-mode loopback "$GPG_FILE" > "$PLAINTEXT_FILE" 2> /dev/null
            
            if [ $? -ne 0 ]; then
                echo "❌ エラー：マスターパスワードが間違っています。"
                continue
            fi
        else
            echo "⚠️  パスワードファイルが見つかりません。"
            continue
        fi

        # 検索と表示
        result=$(grep "^$service_name," "$PLAINTEXT_FILE" 2> /dev/null)
        
        # 検索終わったら即削除
        rm "$PLAINTEXT_FILE"

        echo "---------------------------------"
        if [ -z "$result" ]; then
            echo "そのサービス名は登録されていません。"
        else
            service=$(echo $result | cut -d',' -f 1)
            user=$(echo $result | cut -d',' -f 2)
            pass=$(echo $result | cut -d',' -f 3)

            echo "🔍 検索結果:"
            echo "サービス名: $service"
            echo "ユーザー名: $user"
            echo "パスワード: $pass"
        fi
        echo "---------------------------------"

    elif [ "$choice" == "Exit" ]; then
        echo "Thank you!"
        break
    else
        echo "入力が間違えています。Add Password/Get Password/Exit から入力してください。"
    fi
done