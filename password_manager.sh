#!/bin/bash
echo "パスワードマネージャーへようこそ！"

while true; do
    echo "次の選択肢から入力してください(Add Password/Get Password/Exit):"
    read choice

    if [ "$choice" == "Add Password" ]; then
    echo "サービス名を入力してください:"
    read service_name
    echo "ユーザー名を入力してください:"
    read username
    echo "パスワードを入力してください:"
    read password
    echo "$service_name,$username,$password" >> passwords.txt
    echo "パスワードの追加は成功しました。"

    elif [ "$choice" == "Get Password" ]; then
    echo "サービス名を入力してください:"
    read service_name
    result=$(grep "^$service_name," passwords.txt)
        if [ -z "$result" ]; then
            echo "そのサービス名は登録されていません。"
        else
            service=$(echo $result | cut -d',' -f 1)
            user=$(echo $result | cut -d',' -f 2)
            pass=$(echo $result | cut -d',' -f 3)

            echo "サービス名: $service"
            echo "ユーザー名: $user"
            echo "パスワード: $pass"
        fi
    elif [  "$choice" == "Exit" ]; then
    echo "Thank you"
    break
    fi
done