#!/bin/bash
echo "サービス名を入力してください:"
read service_name
echo "ユーザー名を入力してください:"
read username
echo "パスワードを入力してください:"
read password
echo "Thank you!"

echo "$service_name,$username,$password" >> passwords.txt