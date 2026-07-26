-- 존재하지 않는 회원을 참조하는 FK 테스트
-- member_id = 9999가 없으므로 오류가 발생해야 한다.

INSERT INTO rental (
    member_id,
    book_id,
    rental_date,
    due_date,
    status
)
VALUES (
    9999,
    1,
    CURRENT_DATE,
    CURRENT_DATE + 14,
    'RENTED'
);