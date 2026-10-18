#!/usr/bin/env bash
# Tạo dữ liệu demo cho WordPress bằng WP-CLI (chạy container tạm, không cài gì lên host)
set -e
cd "$(dirname "$0")"
set -a; . ./.env; set +a
SITE_URL="${1:-https://localhost}"
NET="${2:-blog-cms_backend}"

wp() {
  docker run --rm --user 33:33 --volumes-from wordpress --network "$NET" \
    -e WORDPRESS_DB_HOST=db:3306 -e WORDPRESS_DB_NAME="$WP_DB_NAME" \
    -e WORDPRESS_DB_USER="$WP_DB_USER" -e WORDPRESS_DB_PASSWORD="$WP_DB_PASSWORD" \
    wordpress:cli wp --url="$SITE_URL" "$@"
}

echo ">> Tạo danh mục"
C1=$(wp term create category "Công nghệ"  --porcelain)
C2=$(wp term create category "Đời sống"   --porcelain)
C3=$(wp term create category "Học tập"    --porcelain)

echo ">> Tạo bài viết"
wp post create --post_status=publish --post_category=$C1 \
  --post_title="Docker là gì? Vì sao nên dùng container" \
  --post_content="Docker giúp đóng gói ứng dụng cùng môi trường chạy, triển khai nhất quán trên mọi máy."
wp post create --post_status=publish --post_category=$C1 \
  --post_title="Giám sát hệ thống với Prometheus và Grafana" \
  --post_content="Prometheus thu thập metrics, Grafana hiển thị dashboard trực quan cho container, web và database."
wp post create --post_status=publish --post_category=$C2 \
  --post_title="Cân bằng giữa học tập và cuộc sống sinh viên" \
  --post_content="Lập kế hoạch thời gian hợp lý giúp sinh viên vừa học tốt vừa có thời gian nghỉ ngơi."
wp post create --post_status=publish --post_category=$C3 \
  --post_title="Mẹo ghi nhớ kiến thức hiệu quả" \
  --post_content="Ôn tập ngắt quãng, tự kiểm tra và ghi chú bằng sơ đồ là những phương pháp học đã được chứng minh."
wp post create --post_status=publish --post_category=$C3 \
  --post_title="Quản lý mã nguồn với Git và GitHub" \
  --post_content="Commit rõ ràng, chia nhánh hợp lý và viết README đầy đủ giúp dự án dễ bảo trì."

echo ">> Tạo người dùng"
P1=$(openssl rand -base64 18 | tr -d '=+/')
P2=$(openssl rand -base64 18 | tr -d '=+/')
wp user create tacgia1 tacgia1@example.com --role=author --user_pass="$P1"
wp user create bientap1 bientap1@example.com --role=editor --user_pass="$P2"

echo
echo "Xong. Mật khẩu 2 user demo (lưu lại nếu cần đăng nhập):"
echo "  tacgia1  : $P1"
echo "  bientap1 : $P2"
