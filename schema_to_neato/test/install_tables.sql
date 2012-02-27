create table erd_parent (
  id  number primary key,
  txt varchar2(10)
);

create table erd_child_1 (
  id  number primary key,
  id_p references erd_parent,
  txt varchar2(10)
);

create table erd_child_2 (
  id  number primary key,
  id_p references erd_parent,
  txt varchar2(10)
);

create table erd_other (
  id number primary key,
  txt varchar2(10)
);

create table erd_child_2_x_erd_other (
  id_child_2 references erd_child_2,
  id_other   references erd_other,
  txt        varchar2(10)
);
