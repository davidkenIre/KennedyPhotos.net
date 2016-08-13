-- Setup the Photos database0
drop table photo;

drop table album;

drop table blog;

drop table user;

drop table AspNetUsers;

create table album (
	album_id           	int not null primary key auto_increment,
    created_date		datetime not null, 
    created_by			varchar(100) not null,
    updated_date		datetime,
    updated_by			varchar(100),
	album_name			varchar(500) not null,
    album_date			datetime,
    description			varchar(32000),
	location  			varchar(1000) not null,
    active              varchar(1) default 'Y'    
);


create table photo  (
	photo_id 			int not null primary key auto_increment,
    created_date		datetime not null, 
    created_by			varchar(100) not null,
    updated_date		datetime,
    updated_by			varchar(100),    
    album_id			int not null references album(album_id),
	filename 			varchar(1000) not null,
    thumbnail_filename  varchar(1000) not null,
    date_taken          datetime,
    fStop               varchar(100),
    exposure            varchar(100),
    iso                 varchar(100),
    focal_length        varchar(100),
    dimensions          varchar(100),
    Camera_maker	    varchar(100),
    Camera_model		varchar(100),	
    checksum            varchar(100),
    active              varchar(1) default 'Y',
    to_remove           varchar(1) default 'N'    
);

create table blog (
	blog_id 			int not null primary key auto_increment,
    created_date		datetime not null, 
    created_by			varchar(100) not null,
    updated_date		datetime,
    updated_by			varchar(100),        
    title			    varchar(200),    
    author 				varchar(100),    
    blog_text			text(104857600),
    active              varchar(1) default 'Y');
    
create table user (  
	user_id 			int not null primary key auto_increment,
    created_date		datetime not null, 
    created_by			varchar(100) not null,
    updated_date		datetime,
    updated_by			varchar(100),    
    username			varchar(100),    
    password			varchar(100),    
    roles		    	varchar(100));
    
CREATE TABLE AspNetUsers (
    Id                   VARCHAR (128) NOT NULL,
    Email                VARCHAR (256) NULL,
    EmailConfirmed       BIT            NOT NULL,
    PasswordHash         text (32000) NULL,
    SecurityStamp        text (32000) NULL,
    PhoneNumber          text (32000) NULL,
    PhoneNumberConfirmed BIT            NOT NULL,
    TwoFactorEnabled     BIT            NOT NULL,
    LockoutEndDateUtc    DATETIME       NULL,
    LockoutEnabled       BIT            NOT NULL,
    AccessFailedCount    INT            NOT NULL,
    UserName             VARCHAR (256) NOT NULL,
CONSTRAINT AspNetUsers PRIMARY KEY (Id ASC)    
    );

CREATE UNIQUE INDEX UserNameIndex
    ON AspNetUsers(UserName ASC);
    
    
CREATE TABLE AspNetUserClaims (
    Id         INT (1) NOT NULL,
    UserId     VARCHAR (128) NOT NULL,
    ClaimType  text (32000) NULL,
    ClaimValue text (32000) NULL,
    CONSTRAINT AspNetUserClaims PRIMARY KEY (Id ASC),
    CONSTRAINT AspNetUsers_UserId FOREIGN KEY (UserId) REFERENCES AspNetUsers(Id) ON DELETE CASCADE
);

CREATE INDEX IX_UserId
    ON AspNetUserClaims(UserId ASC);
    
    
CREATE TABLE AspNetRoles (
    Id   VARCHAR (128) NOT NULL,
    Name VARCHAR (256) NOT NULL,
    CONSTRAINT AspNetRoles PRIMARY KEY (Id ASC)
);


CREATE UNIQUE INDEX RoleNameIndex
    ON AspNetRoles(Name ASC);


CREATE TABLE AspNetUserLogins (
    LoginProvider VARCHAR (128) NOT NULL,
    ProviderKey  VARCHAR (128) NOT NULL,
    UserId        VARCHAR (128) NOT NULL,
    CONSTRAINT AspNetUserLogins PRIMARY KEY (LoginProvider ASC, ProviderKey ASC, UserId ASC),
    CONSTRAINT AspNetUserLogins_UserId FOREIGN KEY (UserId) REFERENCES AspNetUsers (Id) ON DELETE CASCADE
);


CREATE INDEX IX_UserId
    ON AspNetUserLogins(UserId ASC);


CREATE TABLE AspNetUserRoles (
    UserId VARCHAR (128) NOT NULL,
    RoleId VARCHAR (128) NOT NULL,
    CONSTRAINT AspNetUserRoles PRIMARY KEY (UserId ASC, RoleId ASC),
    CONSTRAINT AspNetRoles_RoleId FOREIGN KEY (RoleId) REFERENCES AspNetRoles (Id) ON DELETE CASCADE,
    CONSTRAINT AspNetRoleUsers_UserId FOREIGN KEY (UserId) REFERENCES AspNetUsers (Id) ON DELETE CASCADE
);


CREATE INDEX IX_UserId
    ON AspNetUserRoles(UserId ASC);


CREATE INDEX IX_RoleId
    ON AspNetUserRoles(RoleId ASC);

    
create table albumaccess (
UserId                   VARCHAR (128) NOT NULL,    
Album_ID                 int,
    created_date		datetime not null, 
    created_by			varchar(100) not null,
    updated_date		datetime,
    updated_by			varchar(100));  
    
create table blogaccess (
UserId                   VARCHAR (128) NOT NULL,    
blog_ID                 int,
    created_date		datetime not null, 
    created_by			varchar(100) not null,
    updated_date		datetime,
    updated_by			varchar(100));      
    
select * from albumaccess where userid = 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3';

select * from albumaccess;

delete from albumaccess;

insert into  blogaccess (userid, blog_id, created_date, created_by) select 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', blog_id, now(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3' from blog where blog_id = 15;

insert into  albumaccess (userid, album_id, created_date, created_by) select 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', album_id, now(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3' from album where active = 'Y';

delete from albumaccess where album_id = 7 and userid = '5e55524b-d9b2-44ee-a006-baa69ee6e1fd';

select * from AspNetUsers;

delete from AspNetUsers where id = '961d9497-e8ad-41dd-9ddf-7766caa6aa69';

select * from album;

SELECT
  DATE_FORMAT(album_date, '%d-%M-%Y') AS your_date from album;

update album set updated_by = 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', updated_date = now(), description = 'Ellies baptism', album_date = STR_TO_DATE('23-4-2016', '%d-%m-%Y') where album_id = 16;

select a.album_name, a.description, a.location, a.album_id,  DATE_FORMAT(a.album_date, '%d-%M-%Y') as album_date from album a, albumaccess aa where a.active = 'Y' and a.album_id = aa.album_id and aa.userid = 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3' order by a.created_date desc;
    
    
select b.* from blog b, blogaccess ba where b.blog_id = ba.blog_id where ba.user_id = '" + UserID + "' and b.active = 'Y' order by created_date desc;


select b.* from blog b, blogaccess ba where b.blog_id = ba.blog_id and ba.user_id = 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3' and b.active = 'Y' order by b.created_date desc;

select * from blogaccess;
    
    
insert into user(created_date, created_by, username, password, roles) values (now(), 'TEMPUSER', 'davidken', 'davidken', 'admin');    
    
select a.*, p.* from photo p, album a, albumaccess aa where a.album_id = p.album_id and a.album_id = 18 and a.active = 'Y' and p.active = 'Y' and aa.userid = '3c1f4e8b-5786-425a-a1b4-43f171eba16d'  and a.album_id = aa.album_id     order by p.date_taken, p.filename;
    
    
select LAST_INSERT_ID() from blog;

delete from blog;    
    
insert into blog (created_date, created_by, title, author, dte_posted, blog_text) values (now(), 'TEMPUSER', 'Iceland Trip Day 1', 'David Kennedy', now(), 'On the road at 6.15. [[/BlogImages/Blog00001.jpg]]Got to airport very early for 12.20 flight. Reached Reyk airport about 2.30 & made our way to hertz where we got our automatic car! Bit of a shaky start from DavidOn the road at 6.15. Got to airport very early for 12.20 flight. Reached Reyk airport about 2.30 & made our way to hertz where we got our automatic car! Bit of a shaky start from DavidOn the road at 6.15. Got to airport very early for 12.20 flight. Reached Reyk airport about 2.30 & made our way to hertz where we got our automatic car! Bit of a shaky start from DavidOn the road at 6.15. Got to airport very early for 12.20 flight. Reached Reyk airport about 2.30 & made our way to hertz where we got our automatic car! Bit of a shaky start from DavidOn the road at 6.15. Got to airport very early for 12.20 flight. Reached Reyk airport about 2.30 & made our way to hertz where we got our automatic car! Bit of a shaky start from DavidOn the road at 6.15. Got to airport very early for 12.20 flight. Reached Reyk airport about 2.30 & made our way to hertz where we got our automatic car! Bit of a shaky start from DavidOn the road at 6.15. Got to airport very early for 12.20 flight. Reached Reyk airport about 2.30 & made our way to hertz where we got our automatic car! Bit of a shaky start from David');

select * from blog;

insert into photo (album_id, filename, thumbnail_filename, date_taken, fStop, exposure1, iso, focal_length, flash, dpi, dimensions, Camera_maker, Camera_model, checksum, created_date, created_by) values (1, 'IMG_7773.JPG', '78b5e582-e7fd-4a7e-ad81-18fd539954e5.JPG', str_to_date('', '%d-%M-%Y %T:%i'), 'xx', 'xxxx', 'xx', 'xx', 'dddd', 'xxx', 'xxx', 'Canon', 'Canon EOS 600D','-1266562611', now(), 'TEMPUSER');

select * from photo order by created_date desc;

select str_to_date('14-May-2016 16:25', 'dd-Mon-yyyy HH:MM') from photo;


select count(*) from photo order by filename;

select photo_id from photo p where lower(thumbnail_filename)='0b72aee9-2c56-414b-a8cd-b57081032281.jpg';

select * from photo;

select * from blog;

update photo set active = 'Y' where filename = 'IMG_1710.JPG';