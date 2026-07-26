# 도서 대여 관리 SQL 미션

백엔드 프레임워크 없이 순수 SQL만으로 "도서 대여 관리" 도메인의 데이터베이스를 설계하고,
데이터 입력부터 조회/조인/집계/서브쿼리/수정/삭제/인덱스까지 핵심 쿼리를 작성·실행한 결과물입니다.

## 1. 개발 환경

- DB: PostgreSQL 18 (로컬)
- 클라이언트: psql CLI
- 표준 SQL을 우선 사용했고, PostgreSQL 전용 문법을 쓴 곳은 해당 SQL 파일 내 주석으로 표시했습니다.
  - `GENERATED ALWAYS AS IDENTITY` (자동 증가 PK)
  - `CURRENT_DATE - INTERVAL '30 days'` (날짜 연산)

## 2. 파일 구성

| 파일 | 설명 |
|---|---|
| [01_schema.sql](01_schema.sql) | 테이블 생성 스크립트 (PK/FK/제약조건 포함, 실행 순서대로 정리) |
| [02_data.sql](02_data.sql) | 샘플 데이터 INSERT (테이블당 10행 이상) |
| [03_queries.sql](03_queries.sql) | 핵심 쿼리 18개 (기본 조회/조인/집계/서브쿼리/수정·삭제/인덱스) |
| [results/](results/) | 위 세 스크립트를 실제 PostgreSQL에서 실행한 결과 텍스트 캡처 |

실행 순서: `01_schema.sql` → `02_data.sql` → `03_queries.sql`

## 3. 테이블 구조 (ERD 요약)

```
category (1) ──< book (N)
member   (1) ──< rental (N)
book     (1) ──< rental (N)
```

| 테이블 | 설명 | PK | FK | 제약조건 |
|---|---|---|---|---|
| category | 도서 카테고리 | category_id | - | category_name UNIQUE, NOT NULL |
| member | 회원 | member_id | - | email UNIQUE, member_name NOT NULL |
| book | 도서 | book_id | category_id → category | isbn UNIQUE, stock_quantity CHECK(>=0) |
| rental | 대여 기록 | rental_id | member_id → member, book_id → book | status CHECK(RENTED/RETURNED/OVERDUE) |

- 1:N 관계 3개: `category → book`, `member → rental`, `book → rental`
- FK가 참조하는 부모 테이블(category, member, book)을 먼저 채운 뒤 rental을 채우도록 `02_data.sql` 순서를 구성했습니다.

## 4. 핵심 쿼리 18개 (03_queries.sql)

| # | 분류 | 내용 |
|---|---|---|
| 1 | 기본 조회 | 재고 3권 이상 도서, 재고 많은 순 (WHERE, ORDER BY) |
| 2 | 기본 조회 | 2015년 이후 출간 도서 상위 5권 (WHERE, ORDER BY, LIMIT) |
| 3 | 기본 조회 | 최근 30일 이내 대여 기록 |
| 4 | 기본 조회 | 연체(OVERDUE) 대여 기록 |
| 5 | 조인(INNER) | 도서 + 카테고리명 |
| 6 | 조인(INNER, 3테이블) | 대여기록 + 회원명 + 도서명 |
| 7 | 조인(LEFT) | 대여 이력 없는 도서 찾기 |
| 8 | 조인(INNER) | 현재 대여 중인 도서·회원 목록 |
| 9 | 집계 | 카테고리별 도서 수 (COUNT + GROUP BY) |
| 10 | 집계 | 회원별 대여 횟수 (COUNT + GROUP BY) |
| 11 | 집계 | 카테고리별 평균 출간연도 (AVG + GROUP BY) |
| 12 | 집계 | 카테고리별 재고 합계 (SUM + GROUP BY) |
| 13 | 서브쿼리 | 대여 기록 없는 회원 찾기 |
| 14 | 서브쿼리 | 평균 재고보다 많은 도서 찾기 |
| 15 | 수정 | 기한 지난 대여 건 상태를 OVERDUE로 UPDATE |
| 16 | 수정 | 특정 도서 재고 수량 보정 UPDATE |
| 17 | 삭제 | 오래된 반납 완료 기록 DELETE |
| 18 | 인덱스 | `rental.member_id`에 인덱스 생성 (회원별 대여 조회가 잦아 조회 성능 개선 목적) |

각 쿼리의 실제 실행 결과는 [results/03_queries_result.txt](results/03_queries_result.txt)에서 확인할 수 있습니다.

## 5. 실행 방법

```bash
psql -U <user> -h localhost -d <database> -f 01_schema.sql
psql -U <user> -h localhost -d <database> -f 02_data.sql
psql -U <user> -h localhost -d <database> -f 03_queries.sql
```
