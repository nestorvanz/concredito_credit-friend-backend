USE [CreditFriends]
GO
/****** Object:  StoredProcedure [dbo].[proc_loan_approvers_read]    Script Date: 2018-09-11 10:42:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_loan_approvers_read]
	@loanID int
as begin	
	select u.userID, u.name
	from LoanApprovers la
	inner join Users u on
		la.userID = u.userID
	where la.loanID = @loanID
end

GO
/****** Object:  StoredProcedure [dbo].[proc_loans_add]    Script Date: 2018-09-11 10:42:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_loans_add]
	@userID int,
	@termID smallint ,
	@amount numeric(10,2),
	@interestAmount numeric(10,2)
as begin
	insert into Loans ( userID, termID, amount, interestAmount, approved, createdAt, pending)
				values(@userID,@termID,@amount,@interestAmount,        0, getdate(),       1);
	select @@IDENTITY as loanID;
end
GO
/****** Object:  StoredProcedure [dbo].[proc_loans_approve]    Script Date: 2018-09-11 10:42:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[proc_loans_approve]
	@loanID int
as begin
	update Loans set pending = 0, approved = 1
	where loanID = @loanID;
end
GO
/****** Object:  StoredProcedure [dbo].[proc_loans_deny]    Script Date: 2018-09-11 10:42:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[proc_loans_deny]
	@loanID int
as begin
	update Loans set pending = 0
	where loanID = @loanID;
end
GO
/****** Object:  StoredProcedure [dbo].[proc_loans_filter]    Script Date: 2018-09-11 10:42:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_loans_filter]
	@loanID int,
	@userID int,
	@pending bit
as begin
	select
		loanID, userID, termID,
		amount, interestAmount, approved,
		createdAt, pending
	from Loans
	where (@loanID is null or loanID = @loanID)
		and (@userID is null or userID = @userID)
		and (@pending is null or pending = @pending);
end
GO
/****** Object:  StoredProcedure [dbo].[proc_loans_pending]    Script Date: 2018-09-11 10:42:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_loans_pending]
	@userID int
as begin
	-- proc_loans_pending 1
	select
		u.userID,
		u.name as userName,
		l.loanID,
		l.termID,
		t.payments,
		t.interest,
		l.amount,
		l.interestAmount,
		l.approved,
		l.createdAt,
		l.pending,
		1 as mapUser,
		1 as mapTerm
	from Users u
	left join Loans l on
		u.userID = l.userID
		and pending = 1
	left join Terms t on
		l.termID = t.termID
	where u.userID = @userID;
end
GO
/****** Object:  StoredProcedure [dbo].[proc_loans_to_approve]    Script Date: 2018-09-11 10:42:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_loans_to_approve]
	@userID int
as begin
	-- proc_loans_to_approve 1
	select
		l.loanID,
		l.userID,
		u.name as userName,
		l.termID,
		l.amount,
		l.interestAmount,
		l.approved,
		l.createdAt,
		l.pending,
		1 as mapUser
	from Loans l
	inner join Users u on
		l.userID = u.userID
	where l.userID != @userID
		and l.pending = 1;
end
GO
/****** Object:  StoredProcedure [dbo].[proc_terms_read]    Script Date: 2018-09-11 10:42:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_terms_read]
	@termID smallint
as begin
	select termID, payments, interest
	from Terms
	where (@termID is null or termID = @termID)
end
GO
/****** Object:  StoredProcedure [dbo].[proc_users_read]    Script Date: 2018-09-11 10:42:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[proc_users_read]
	@userID int
as begin
	select userID, name, token
	from users
	where userID = @userID
end
GO
/****** Object:  StoredProcedure [dbo].[proc_users_sign_in]    Script Date: 2018-09-11 10:42:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_users_sign_in]
	@name varchar(50),
	@token text
as begin
	-- proc_user_signin 'nestor', '123'

	-- Crear usuario si no existe
	if (select count(1) from users where name = @name) = 0 begin
		insert into Users (name, token)
		values (@name, @token);
	end else begin -- Actualizar token de usuario
		update Users set token = @token where name = @name;
	end

	-- Seleccionar usuario que coincida con el nombre enviado.
	select userID, name, token
	from Users
	where name = @name
end
GO
/****** Object:  Table [dbo].[LoanApprovers]    Script Date: 2018-09-11 10:42:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LoanApprovers](
	[loanID] [int] NOT NULL,
	[userID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[loanID] ASC,
	[userID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Loans]    Script Date: 2018-09-11 10:42:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Loans](
	[loanID] [int] IDENTITY(1,1) NOT NULL,
	[userID] [int] NOT NULL,
	[termID] [smallint] NOT NULL,
	[amount] [numeric](10, 2) NOT NULL,
	[interestAmount] [numeric](10, 2) NOT NULL,
	[approved] [bit] NOT NULL,
	[createdAt] [datetime] NOT NULL,
	[pending] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[loanID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Terms]    Script Date: 2018-09-11 10:42:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Terms](
	[termID] [smallint] IDENTITY(1,1) NOT NULL,
	[payments] [smallint] NOT NULL,
	[interest] [numeric](5, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[termID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Users]    Script Date: 2018-09-11 10:42:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Users](
	[userID] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NULL,
	[token] [text] NULL,
PRIMARY KEY CLUSTERED 
(
	[userID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET IDENTITY_INSERT [dbo].[Loans] ON 

INSERT [dbo].[Loans] ([loanID], [userID], [termID], [amount], [interestAmount], [approved], [createdAt], [pending]) VALUES (10, 1, 1, CAST(100.00 AS Numeric(10, 2)), CAST(5.00 AS Numeric(10, 2)), 1, CAST(0x0000A9580002DE72 AS DateTime), 0)
INSERT [dbo].[Loans] ([loanID], [userID], [termID], [amount], [interestAmount], [approved], [createdAt], [pending]) VALUES (11, 1, 2, CAST(200.00 AS Numeric(10, 2)), CAST(14.00 AS Numeric(10, 2)), 0, CAST(0x0000A9580013F34B AS DateTime), 0)
INSERT [dbo].[Loans] ([loanID], [userID], [termID], [amount], [interestAmount], [approved], [createdAt], [pending]) VALUES (12, 1, 3, CAST(300.00 AS Numeric(10, 2)), CAST(36.00 AS Numeric(10, 2)), 0, CAST(0x0000A958001F965D AS DateTime), 0)
INSERT [dbo].[Loans] ([loanID], [userID], [termID], [amount], [interestAmount], [approved], [createdAt], [pending]) VALUES (13, 1, 1, CAST(50.00 AS Numeric(10, 2)), CAST(2.50 AS Numeric(10, 2)), 1, CAST(0x0000A95800385808 AS DateTime), 0)
INSERT [dbo].[Loans] ([loanID], [userID], [termID], [amount], [interestAmount], [approved], [createdAt], [pending]) VALUES (14, 3, 1, CAST(123.00 AS Numeric(10, 2)), CAST(6.15 AS Numeric(10, 2)), 1, CAST(0x0000A9580040B44C AS DateTime), 0)
INSERT [dbo].[Loans] ([loanID], [userID], [termID], [amount], [interestAmount], [approved], [createdAt], [pending]) VALUES (15, 3, 2, CAST(123.00 AS Numeric(10, 2)), CAST(8.61 AS Numeric(10, 2)), 1, CAST(0x0000A9580040FB97 AS DateTime), 0)
INSERT [dbo].[Loans] ([loanID], [userID], [termID], [amount], [interestAmount], [approved], [createdAt], [pending]) VALUES (16, 3, 1, CAST(543.00 AS Numeric(10, 2)), CAST(27.15 AS Numeric(10, 2)), 0, CAST(0x0000A9580042272A AS DateTime), 0)
INSERT [dbo].[Loans] ([loanID], [userID], [termID], [amount], [interestAmount], [approved], [createdAt], [pending]) VALUES (17, 3, 3, CAST(324.00 AS Numeric(10, 2)), CAST(38.88 AS Numeric(10, 2)), 1, CAST(0x0000A9580042ADB1 AS DateTime), 0)
INSERT [dbo].[Loans] ([loanID], [userID], [termID], [amount], [interestAmount], [approved], [createdAt], [pending]) VALUES (18, 1, 3, CAST(234.00 AS Numeric(10, 2)), CAST(28.08 AS Numeric(10, 2)), 1, CAST(0x0000A9580042EE8C AS DateTime), 0)
INSERT [dbo].[Loans] ([loanID], [userID], [termID], [amount], [interestAmount], [approved], [createdAt], [pending]) VALUES (19, 3, 2, CAST(123.00 AS Numeric(10, 2)), CAST(8.61 AS Numeric(10, 2)), 0, CAST(0x0000A958004309E2 AS DateTime), 0)
SET IDENTITY_INSERT [dbo].[Loans] OFF
SET IDENTITY_INSERT [dbo].[Terms] ON 

INSERT [dbo].[Terms] ([termID], [payments], [interest]) VALUES (1, 3, CAST(5.00 AS Numeric(5, 2)))
INSERT [dbo].[Terms] ([termID], [payments], [interest]) VALUES (2, 6, CAST(7.00 AS Numeric(5, 2)))
INSERT [dbo].[Terms] ([termID], [payments], [interest]) VALUES (3, 9, CAST(12.00 AS Numeric(5, 2)))
SET IDENTITY_INSERT [dbo].[Terms] OFF
SET IDENTITY_INSERT [dbo].[Users] ON 

INSERT [dbo].[Users] ([userID], [name], [token]) VALUES (1, N'nestor', N'1536619650150')
INSERT [dbo].[Users] ([userID], [name], [token]) VALUES (2, N'1', N'1536472994201')
INSERT [dbo].[Users] ([userID], [name], [token]) VALUES (3, N'azucena', N'1536651072786')
SET IDENTITY_INSERT [dbo].[Users] OFF
ALTER TABLE [dbo].[Loans] ADD  DEFAULT ((0)) FOR [approved]
GO
ALTER TABLE [dbo].[Loans] ADD  DEFAULT (getdate()) FOR [createdAt]
GO
ALTER TABLE [dbo].[Loans] ADD  DEFAULT ((1)) FOR [pending]
GO
ALTER TABLE [dbo].[LoanApprovers]  WITH CHECK ADD FOREIGN KEY([loanID])
REFERENCES [dbo].[Loans] ([loanID])
GO
ALTER TABLE [dbo].[LoanApprovers]  WITH CHECK ADD FOREIGN KEY([userID])
REFERENCES [dbo].[Users] ([userID])
GO
ALTER TABLE [dbo].[Loans]  WITH CHECK ADD FOREIGN KEY([termID])
REFERENCES [dbo].[Terms] ([termID])
GO
ALTER TABLE [dbo].[Loans]  WITH CHECK ADD FOREIGN KEY([userID])
REFERENCES [dbo].[Users] ([userID])
GO
