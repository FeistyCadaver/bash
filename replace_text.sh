#!/bin/bash

# Скрипт replace_text.sh
# Заменяет в файлах указанной директории (или в одном файле) строку поиска на строку замены
# Аргументы:
# $1 - строка поиска
# $2 - строка замены
# $3 - файл или директория (если указано -1, читаем из stdin, считаем что нет)
# $4 - опция -r для рекурсивного поиска в директориях (может отсутствовать)

SEARCH="$1"
REPLACE="$2"
TARGET="$3"
RECURSIVE=""

# Проверяем последний аргумент на -r
if [[ "$4" == "-r" ]]; then
  RECURSIVE=1
fi

# Функция для замены текста в одном файле
replace_in_file() {
  local file=$1
  # считаем изначальное количество вхождений
  local count_before=$(grep -o -- "$SEARCH" "$file" | wc -l)
  if [[ $count_before -gt 0 ]]; then
    # используем sed inplace (для совместимости с GNU sed и BSD sed)
    # сначала бэкап копим, потом удаляем
    sed -i.bak "s/$SEARCH/$REPLACE/g" "$file"
    rm "$file.bak"
  fi
  echo "$count_before"
}

total_replacements=0

if [[ "$TARGET" == "-1" ]]; then
  echo "Аргумент -1 не поддерживается для поиска в stdin в данной реализации."
  exit 1
fi

if [[ -f "$TARGET" ]]; then
  # одиночный файл
  replaced=$(replace_in_file "$TARGET")
  total_replacements=$((total_replacements + replaced))
  echo "Replaced $replaced entries in file $TARGET"
elif [[ -d "$TARGET" ]]; then
  # папка
  if [[ "$RECURSIVE" == "1" ]]; then
    # Рекурсивно обрабатываем все файлы
    while IFS= read -r -d '' file; do
      replaced=$(replace_in_file "$file")
      total_replacements=$((total_replacements + replaced))
      if [[ $replaced -gt 0 ]]; then
        echo "Replaced $replaced entries in file $file"
      fi
    done < <(find "$TARGET" -type f -print0)
  else
    # Обрабатываем только файлы в текущей директории (без рекурсии)
    for file in "$TARGET"/*; do
      if [[ -f "$file" ]]; then
        replaced=$(replace_in_file "$file")
        total_replacements=$((total_replacements + replaced))
        if [[ $replaced -gt 0 ]]; then
          echo "Replaced $replaced entries in file $file"
        fi
      fi
    done
  fi
else
  echo "Ошибка: $TARGET не файл и не директория"
  exit 1
fi

echo "Всего заменено записей: $total_replacements"
