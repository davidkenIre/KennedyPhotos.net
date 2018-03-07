-- Create the user
CREATE USER 'kennedyphotos'@'%.lattuce.com' IDENTIFIED BY 'kppass01$';

-- Setup the Photos database
----------------------------

-- Drops in case we are recreating
drop table photo;

drop table album;

drop table blog;

drop table user;

drop table AspNetUsers;

create table photos.album (
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


create table photos.photo  (
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

create table photos.blog (
	blog_id 			int not null primary key auto_increment,
    created_date		datetime not null, 
    created_by			varchar(100) not null,
    updated_date		datetime,
    updated_by			varchar(100),        
    title			    varchar(200),    
    author 				varchar(100),    
    blog_text			text(104857600),
    active              varchar(1) default 'Y');
    
create table photos.user (  
	user_id 			int not null primary key auto_increment,
    created_date		datetime not null, 
    created_by			varchar(100) not null,
    updated_date		datetime,
    updated_by			varchar(100),    
    username			varchar(100),    
    password			varchar(100),    
    roles		    	varchar(100));
    
CREATE TABLE photos.AspNetUsers (
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
    ON photos.AspNetUsers(UserName ASC);
    
    
CREATE TABLE photos.AspNetUserClaims (
    Id         INT (1) NOT NULL,
    UserId     VARCHAR (128) NOT NULL,
    ClaimType  text (32000) NULL,
    ClaimValue text (32000) NULL,
    CONSTRAINT AspNetUserClaims PRIMARY KEY (Id ASC),
    CONSTRAINT AspNetUsers_UserId FOREIGN KEY (UserId) REFERENCES AspNetUsers(Id) ON DELETE CASCADE
);

CREATE INDEX IX_UserId
    ON photos.AspNetUserClaims(UserId ASC);
    
    
CREATE TABLE photos.AspNetRoles (
    Id   VARCHAR (128) NOT NULL,
    Name VARCHAR (256) NOT NULL,
    CONSTRAINT AspNetRoles PRIMARY KEY (Id ASC)
);


CREATE UNIQUE INDEX RoleNameIndex
    ON photos.AspNetRoles(Name ASC);


CREATE TABLE photos.AspNetUserLogins (
    LoginProvider VARCHAR (128) NOT NULL,
    ProviderKey  VARCHAR (128) NOT NULL,
    UserId        VARCHAR (128) NOT NULL,
    CONSTRAINT AspNetUserLogins PRIMARY KEY (LoginProvider ASC, ProviderKey ASC, UserId ASC),
    CONSTRAINT AspNetUserLogins_UserId FOREIGN KEY (UserId) REFERENCES AspNetUsers (Id) ON DELETE CASCADE
);


CREATE INDEX IX_UserId
    ON AspNetUserLogins(UserId ASC);


CREATE TABLE photos.AspNetUserRoles (
    UserId VARCHAR (128) NOT NULL,
    RoleId VARCHAR (128) NOT NULL,
    CONSTRAINT AspNetUserRoles PRIMARY KEY (UserId ASC, RoleId ASC),
    CONSTRAINT AspNetRoles_RoleId FOREIGN KEY (RoleId) REFERENCES AspNetRoles (Id) ON DELETE CASCADE,
    CONSTRAINT AspNetRoleUsers_UserId FOREIGN KEY (UserId) REFERENCES AspNetUsers (Id) ON DELETE CASCADE
);


CREATE INDEX IX_UserId
    ON photos.AspNetUserRoles(UserId ASC);


CREATE INDEX IX_RoleId
    ON photos.AspNetUserRoles(RoleId ASC);

    
create table photos.albumaccess (
UserId                   VARCHAR (128) NOT NULL,    
Album_ID                 int,
    created_date		datetime not null, 
    created_by			varchar(100) not null,
    updated_date		datetime,
    updated_by			varchar(100));  
    
create table photos.blogaccess (
UserId                   VARCHAR (128) NOT NULL,    
blog_ID                 int,
    created_date		datetime not null, 
    created_by			varchar(100) not null,
    updated_date		datetime,
    updated_by			varchar(100));      

-- Grants
GRANT ALL PRIVILEGES on photos.*
TO 'kennedyphotos'@'%.lattuce.com'
IDENTIFIED BY 'kppass01$';