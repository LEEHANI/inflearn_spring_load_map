-- http://localhost:8082/login.do?jsessionid=bfd542a82b05b70c7cbd920706ae935d
drop table if exists member CASCADE;
create table member
(
 id bigint generated by default as identity,
 name varchar(255),
 primary key (id)
);