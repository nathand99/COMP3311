-- COMP3311 Prac 03 Exercise
-- Schema for simple company database

create table Employees (
	tfn         char(11) CHECK (id LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9]'),
	givenName   varchar(30) NOT NULL,
	familyName  varchar(30),
	hoursPweek  float CHECK (hoursPweek <= 168 AND hoursPweek >= 0),
	PRIMARY KEY(tfn)
);

create table Departments (
	id          char(3) CHECK (id LIKE '[0-9][0-9][0-9]'),
	name        varchar(100) UNIQUE,
	manager     char(11) UNIQUE,
	PRIMARY KEY(id)
);

create table DeptMissions (
	department  char(3) REFERENCES Departments (id),
	keyword     varchar(20)
);

create table WorksFor (
	employee    char(11) REFERENCES Employees (tfn),
	department  char(3),
	percentage  float CHECK (percentage > 0 AND percentage <= 100)
);
