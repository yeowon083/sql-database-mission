-- FK 정상 참조 테스트
SELECT *
FROM category
WHERE category_id = 1;

BEGIN;

INSERT INTO book (
    title,
    author,
    category_id
)
VALUES (
    'FK 정상 테스트 도서',
    '테스트 작가',
    1
);

SELECT *
FROM book
WHERE title = 'FK 정상 테스트 도서';

ROLLBACK;


-- FK 없는 값 참조 테스트
INSERT INTO book (
    title,
    author,
    category_id
)
VALUES (
    'FK 오류 테스트 도서',
    '테스트 작가',
    9999
);