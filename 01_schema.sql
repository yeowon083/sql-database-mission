-- =========================================================
-- 도서 대여 관리 시스템 - 스키마 생성 스크립트
-- DB: PostgreSQL 18
-- 실행 순서: category -> member -> book -> rental
-- =========================================================

-- 기존 테이블 정리 (재실행 가능하도록 자식 -> 부모 순으로 DROP)
DROP TABLE IF EXISTS rental;
DROP TABLE IF EXISTS book;
DROP TABLE IF EXISTS member;
DROP TABLE IF EXISTS category;

-- ---------------------------------------------------------
-- 1. category (도서 카테고리)
-- ---------------------------------------------------------
CREATE TABLE category (
    category_id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- PostgreSQL 전용: IDENTITY 자동증가 컬럼
    category_name VARCHAR(50) NOT NULL UNIQUE,                      -- 카테고리명 중복 방지
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------
-- 2. member (회원)
-- ---------------------------------------------------------
CREATE TABLE member (
    member_id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,   -- PostgreSQL 전용: IDENTITY 자동증가 컬럼
    member_name VARCHAR(50)  NOT NULL,
    email       VARCHAR(100) NOT NULL UNIQUE,                       -- 이메일 중복 가입 방지
    phone       VARCHAR(20),
    joined_at   DATE NOT NULL DEFAULT CURRENT_DATE
);

-- ---------------------------------------------------------
-- 3. book (도서) : category(1) - book(N)
-- ---------------------------------------------------------
CREATE TABLE book (
    book_id         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- PostgreSQL 전용: IDENTITY 자동증가 컬럼
    title           VARCHAR(200) NOT NULL,
    author          VARCHAR(100) NOT NULL,
    category_id     INTEGER NOT NULL,
    published_year  INTEGER,
    isbn            VARCHAR(20) UNIQUE,                               -- ISBN 중복 등록 방지
    stock_quantity  INTEGER NOT NULL DEFAULT 1 CHECK (stock_quantity >= 0),
    CONSTRAINT fk_book_category
        FOREIGN KEY (category_id) REFERENCES category(category_id)
);

-- ---------------------------------------------------------
-- 4. rental (대여 기록) : member(1) - rental(N), book(1) - rental(N)
-- ---------------------------------------------------------
CREATE TABLE rental (
    rental_id    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,  -- PostgreSQL 전용: IDENTITY 자동증가 컬럼
    member_id    INTEGER NOT NULL,
    book_id      INTEGER NOT NULL,
    rental_date  DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date     DATE NOT NULL,
    return_date  DATE,                                              -- NULL이면 아직 반납 전
    status       VARCHAR(20) NOT NULL DEFAULT 'RENTED'
                 CHECK (status IN ('RENTED', 'RETURNED', 'OVERDUE')),
    CONSTRAINT fk_rental_member
        FOREIGN KEY (member_id) REFERENCES member(member_id),
    CONSTRAINT fk_rental_book
        FOREIGN KEY (book_id) REFERENCES book(book_id)
);
