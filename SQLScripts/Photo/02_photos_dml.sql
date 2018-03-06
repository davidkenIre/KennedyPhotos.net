select * from blog;

select * from aspnetusers;

select b.blog_id, Title, Author, Blog_Text, 
	            GREATEST(b.CREATED_DATE, b.UPDATED_DATE) as dte_posted
            from blog b, blogaccess ba
            where b.blog_id =  17
            and b.blog_id = ba.blog_id
            and ba.userid = 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3'  
            union
            select b.blog_id, Title, Author, Blog_Text, 
	            GREATEST(b.CREATED_DATE, ifnull(b.UPDATED_DATE, b.CREATED_DATE)) as dte_posted
            from blog b, aspnetroles ar2, aspnetuserroles aur2
            where b.blog_id =  17
            and aur2.userid = 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3'  
            and aur2.RoleId = ar2.Id
            and ar2.Name = 'Admin';