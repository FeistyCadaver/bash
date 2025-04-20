#!/bin/bash

# Проверка количества аргументов
if [ "$#" -lt 3 ]; then
    echo "Использование: $0 'строка поиска' 'строка замены' файл(-директория) [-g]"
    exit 1
fi

search_string="$1"
replace_string="$2"
target="$3"
recursive=false

# Проверка на наличие флага -g
if [[ "$4" == "-g" ]]; then
    recursive=true
fi

# Функция для замены текста в файле
replace_in_file() {
    local file="$1"
    local count=$(grep -o "$search_string" "$file" | wc -l)

    if [ "$count" -gt 0 ]; then
        sed -i "s/$search_string/$replace_string/g" "$file"
        echo "Replaced $count entries in $file"
    fi
}

# Если указан файл
if [ -f "$target" ]; then
    replace_in_file "$target"

# Если указана директория
elif [ -d "$target" ]; then
    if $recursive; then
        # Рекурсивный поиск и замена в директории
        find "$target" -type f | while read -r file; do
            replace_in_file "$file"
        done
    else
        # Поиск и замена только в файлах в директории
        for file in "$target"/*; do
            if [ -f "$file" ]; then
                replace_in_file "$file"
            fi
        done
    fi
else
    echo "Ошибка: '$target' не является файлом или директорией."
    exit 1
fi
