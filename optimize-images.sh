#!/bin/bash

echo "=========================================="
echo "Оптимизация фотографий для веб-сайта"
echo "=========================================="
echo ""

# Переходим в директорию скрипта
cd "$(dirname "$0")"

# Счетчик
total=0
optimized=0

# Функция оптимизации
optimize_image() {
    local file="$1"
    local size=$(stat -f%z "$file")

    # Если файл больше 500KB - оптимизируем
    if [ $size -gt 512000 ]; then
        echo "Оптимизируя: $(basename "$file") ($(($size / 1024))KB)"

        # Создаем временный файл
        local temp="${file}.tmp"

        # Уменьшаем до максимум 1920px по длинной стороне и сжимаем
        sips --resampleHeightWidthMax 1920 --setProperty formatOptions 85 "$file" --out "$temp" > /dev/null 2>&1

        if [ $? -eq 0 ]; then
            mv "$temp" "$file"
            local new_size=$(stat -f%z "$file")
            echo "  ✓ Сжато до $(($new_size / 1024))KB (экономия: $(( ($size - $new_size) / 1024 ))KB)"
            ((optimized++))
        else
            rm -f "$temp"
            echo "  ✗ Ошибка оптимизации"
        fi
    fi

    ((total++))
}

# Оптимизируем все фото в папках категорий
for category in sports classic luxury action; do
    echo ""
    echo "Обработка категории: $category"
    echo "---"

    find "images/$category" -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) 2>/dev/null | while read -r img; do
        optimize_image "$img"
    done
done

echo ""
echo "=========================================="
echo "✅ Готово!"
echo "Обработано файлов: $total"
echo "Оптимизировано: $optimized"
echo ""

# Проверяем итоговый размер
total_size=$(du -sh images/ | awk '{print $1}')
echo "Общий размер папки images: $total_size"
echo "=========================================="
