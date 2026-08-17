-- =========================================================
-- 도서 대여 관리 시스템 - 핵심 쿼리 모음 (총 18개)
-- DB: PostgreSQL 18
-- 01_schema.sql, 02_data.sql 실행 이후에 실행할 것
-- =========================================================


-- =========================================================
-- [기본 조회] 4개 (WHERE, ORDER BY, LIMIT 포함)
-- =========================================================

-- 1. 재고가 3권 이상인 도서를 재고가 많은 순으로 조회
SELECT title, author, stock_quantity
FROM book
WHERE stock_quantity >= 3
ORDER BY stock_quantity DESC;

-- 2. 2015년 이후 출간된 도서 중 최신 출간순 상위 5권 조회
SELECT title, author, published_year
FROM book
WHERE published_year >= 2015
ORDER BY published_year DESC
LIMIT 5;

-- 3. 최근 30일 이내(오늘 기준) 대여된 기록 조회
-- PostgreSQL 전용 문법: CURRENT_DATE - INTERVAL '30 days'
SELECT rental_id, member_id, book_id, rental_date, status
FROM rental
WHERE rental_date >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY rental_date DESC;

-- 4. 현재 연체(OVERDUE) 상태인 대여 기록 조회
SELECT rental_id, member_id, book_id, due_date, status
FROM rental
WHERE status = 'OVERDUE'
ORDER BY due_date;


-- =========================================================
-- [조인] 4개 (INNER JOIN 2개 이상, LEFT JOIN 1개 이상 포함)
-- =========================================================

-- 5. INNER JOIN: 도서 목록과 소속 카테고리명을 함께 조회
SELECT b.title, b.author, c.category_name
FROM book b
INNER JOIN category c ON b.category_id = c.category_id
ORDER BY c.category_name, b.title;

-- 6. INNER JOIN(3개 테이블): 대여 기록에 회원명과 도서명을 함께 조회
SELECT r.rental_id, m.member_name, b.title, r.rental_date, r.status
FROM rental r
INNER JOIN member m ON r.member_id = m.member_id
INNER JOIN book b ON r.book_id = b.book_id
ORDER BY r.rental_date DESC;

-- 7. LEFT JOIN: 전체 도서에 대해 대여 이력이 없는 도서까지 포함하여 대여 횟수 확인
SELECT b.title, r.rental_id
FROM book b
LEFT JOIN rental r ON b.book_id = r.book_id
WHERE r.rental_id IS NULL;

-- 8. INNER JOIN: 현재 대여 중(RENTED)인 도서와 대여한 회원 목록
SELECT m.member_name, b.title, r.rental_date, r.due_date
FROM rental r
INNER JOIN member m ON r.member_id = m.member_id
INNER JOIN book b ON r.book_id = b.book_id
WHERE r.status = 'RENTED'
ORDER BY r.due_date;


-- =========================================================
-- [집계] 4개 (COUNT, SUM, AVG 중 2개 이상 + GROUP BY)
-- =========================================================

-- 9. 카테고리별 보유 도서 수 집계
SELECT c.category_name, COUNT(b.book_id) AS book_count
FROM category c
LEFT JOIN book b ON c.category_id = b.category_id
GROUP BY c.category_name
ORDER BY book_count DESC;

-- 10. 회원별 총 대여 횟수 집계 (대여 많은 순)
SELECT m.member_name, COUNT(r.rental_id) AS rental_count
FROM member m
INNER JOIN rental r ON m.member_id = r.member_id
GROUP BY m.member_name
ORDER BY rental_count DESC;

-- 11. 카테고리별 평균 출간연도 집계
SELECT c.category_name, ROUND(AVG(b.published_year)) AS avg_published_year
FROM category c
INNER JOIN book b ON c.category_id = b.category_id
GROUP BY c.category_name
ORDER BY avg_published_year DESC;

-- 12. 카테고리별 총 재고 수량 집계
SELECT c.category_name, SUM(b.stock_quantity) AS total_stock
FROM category c
INNER JOIN book b ON c.category_id = b.category_id
GROUP BY c.category_name
ORDER BY total_stock DESC;


-- =========================================================
-- [서브쿼리] 2개
-- =========================================================

-- 13. 대여 기록이 한 번도 없는 회원 찾기
SELECT member_name, email
FROM member
WHERE member_id NOT IN (SELECT DISTINCT member_id FROM rental);

-- 14. 전체 도서 평균 재고보다 재고가 많은 도서 찾기
SELECT title, stock_quantity
FROM book
WHERE stock_quantity > (SELECT AVG(stock_quantity) FROM book)
ORDER BY stock_quantity DESC;


-- =========================================================
-- [데이터 수정 및 삭제] 3개
-- =========================================================

-- 15. UPDATE: 반납 기한(due_date)이 지났는데 아직 반납되지 않은 대여 건을 연체(OVERDUE) 상태로 갱신
UPDATE rental
SET status = 'OVERDUE'
WHERE status = 'RENTED'
  AND return_date IS NULL
  AND due_date < CURRENT_DATE;

-- 16. UPDATE: 도서 재입고로 특정 도서(book_id = 5)의 재고 수량 +2 보정
UPDATE book
SET stock_quantity = stock_quantity + 2
WHERE book_id = 5;

-- 17. DELETE: 반납 완료 후 오래된(2026-06-25 이전 반납) 대여 기록 정리
DELETE FROM rental
WHERE status = 'RETURNED'
  AND return_date < '2026-06-25';


-- =========================================================
-- [인덱스] 1개 이상
-- =========================================================

-- 18. rental.member_id에 인덱스 생성
-- 적용 이유: 회원별 대여 내역 조회(WHERE member_id = ...)가 자주 발생하므로
--           FK 컬럼에 인덱스를 걸어 조회 성능을 개선한다.
CREATE INDEX idx_rental_member_id ON rental(member_id);
