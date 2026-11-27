SET XACT_ABORT ON;
BEGIN TRANSACTION;

CREATE TABLE dbo.users (
  user_id UNIQUEIDENTIFIER NOT NULL
    CONSTRAINT DF_users_user_id DEFAULT (NEWSEQUENTIALID()),
  name NVARCHAR(200) NOT NULL,
  email NVARCHAR(320) COLLATE Latin1_General_100_CI_AS NULL,
  phone VARCHAR(16) NOT NULL,
  preferred_language VARCHAR(10) NOT NULL
    CONSTRAINT DF_users_preferred_language DEFAULT ('en'),
  created_at DATETIME2(3) NOT NULL
    CONSTRAINT DF_users_created_at DEFAULT (SYSUTCDATETIME()),
  updated_at DATETIME2(3) NOT NULL
    CONSTRAINT DF_users_updated_at DEFAULT (SYSUTCDATETIME()),
  CONSTRAINT PK_users PRIMARY KEY (user_id),
  CONSTRAINT CK_users_name CHECK (LEN(LTRIM(RTRIM(name))) > 0),
  CONSTRAINT CK_users_phone_e164 CHECK (
    phone LIKE '+[1-9]%'
    AND phone NOT LIKE '%[^0-9+]%'
    AND phone NOT LIKE '+%+%'
    AND LEN(phone) BETWEEN 8 AND 16
  ),
  CONSTRAINT CK_users_preferred_language
    CHECK (preferred_language IN ('en', 'hi'))
);

CREATE UNIQUE INDEX UX_users_email
  ON dbo.users (email)
  WHERE email IS NOT NULL;

CREATE UNIQUE INDEX UX_users_phone ON dbo.users (phone);

CREATE TABLE dbo.locations (
  location_id UNIQUEIDENTIFIER NOT NULL
    CONSTRAINT DF_locations_location_id DEFAULT (NEWSEQUENTIALID()),
  site_name NVARCHAR(200) NOT NULL,
  site_address NVARCHAR(500) NOT NULL,
  latitude DECIMAL(9, 6) NOT NULL,
  longitude DECIMAL(9, 6) NOT NULL,
  capacity INT NOT NULL,
  created_at DATETIME2(3) NOT NULL
    CONSTRAINT DF_locations_created_at DEFAULT (SYSUTCDATETIME()),
  updated_at DATETIME2(3) NOT NULL
    CONSTRAINT DF_locations_updated_at DEFAULT (SYSUTCDATETIME()),
  CONSTRAINT PK_locations PRIMARY KEY (location_id),
  CONSTRAINT CK_locations_site_name
    CHECK (LEN(LTRIM(RTRIM(site_name))) > 0),
  CONSTRAINT CK_locations_site_address
    CHECK (LEN(LTRIM(RTRIM(site_address))) > 0),
  CONSTRAINT CK_locations_latitude CHECK (latitude BETWEEN -90 AND 90),
  CONSTRAINT CK_locations_longitude CHECK (longitude BETWEEN -180 AND 180),
  CONSTRAINT CK_locations_capacity CHECK (capacity >= 0)
);

CREATE TABLE dbo.visits (
  visit_id UNIQUEIDENTIFIER NOT NULL
    CONSTRAINT DF_visits_visit_id DEFAULT (NEWSEQUENTIALID()),
  user_id UNIQUEIDENTIFIER NOT NULL,
  location_id UNIQUEIDENTIFIER NOT NULL,
  entry_time DATETIME2(3) NOT NULL
    CONSTRAINT DF_visits_entry_time DEFAULT (SYSUTCDATETIME()),
  exit_time DATETIME2(3) NULL,
  status VARCHAR(16) NOT NULL
    CONSTRAINT DF_visits_status DEFAULT ('active'),
  created_at DATETIME2(3) NOT NULL
    CONSTRAINT DF_visits_created_at DEFAULT (SYSUTCDATETIME()),
  updated_at DATETIME2(3) NOT NULL
    CONSTRAINT DF_visits_updated_at DEFAULT (SYSUTCDATETIME()),
  CONSTRAINT PK_visits PRIMARY KEY (visit_id),
  CONSTRAINT FK_visits_users FOREIGN KEY (user_id)
    REFERENCES dbo.users (user_id) ON DELETE CASCADE,
  CONSTRAINT FK_visits_locations FOREIGN KEY (location_id)
    REFERENCES dbo.locations (location_id),
  CONSTRAINT CK_visits_status
    CHECK (status IN ('active', 'completed', 'cancelled')),
  CONSTRAINT CK_visits_exit_time
    CHECK (exit_time IS NULL OR exit_time >= entry_time),
  CONSTRAINT CK_visits_completed_exit
    CHECK (status <> 'completed' OR exit_time IS NOT NULL),
  CONSTRAINT CK_visits_active_exit
    CHECK (status <> 'active' OR exit_time IS NULL)
);

CREATE INDEX IX_visits_user_entry_time
  ON dbo.visits (user_id, entry_time DESC);

CREATE INDEX IX_visits_location_entry_time
  ON dbo.visits (location_id, entry_time DESC);

CREATE INDEX IX_visits_active_location
  ON dbo.visits (location_id, entry_time)
  WHERE status = 'active';

CREATE TABLE dbo.admins (
  admin_id UNIQUEIDENTIFIER NOT NULL
    CONSTRAINT DF_admins_admin_id DEFAULT (NEWSEQUENTIALID()),
  name NVARCHAR(200) NOT NULL,
  email NVARCHAR(320) COLLATE Latin1_General_100_CI_AS NOT NULL,
  password_hash NVARCHAR(500) NOT NULL,
  role VARCHAR(24) NOT NULL
    CONSTRAINT DF_admins_role DEFAULT ('site_admin'),
  location_id UNIQUEIDENTIFIER NOT NULL,
  created_at DATETIME2(3) NOT NULL
    CONSTRAINT DF_admins_created_at DEFAULT (SYSUTCDATETIME()),
  updated_at DATETIME2(3) NOT NULL
    CONSTRAINT DF_admins_updated_at DEFAULT (SYSUTCDATETIME()),
  CONSTRAINT PK_admins PRIMARY KEY (admin_id),
  CONSTRAINT FK_admins_locations FOREIGN KEY (location_id)
    REFERENCES dbo.locations (location_id),
  CONSTRAINT CK_admins_name CHECK (LEN(LTRIM(RTRIM(name))) > 0),
  CONSTRAINT CK_admins_email CHECK (LEN(LTRIM(RTRIM(email))) > 0),
  CONSTRAINT CK_admins_password_hash
    CHECK (LEN(LTRIM(RTRIM(password_hash))) > 0),
  CONSTRAINT CK_admins_role
    CHECK (role IN ('site_admin', 'location_manager', 'operator'))
);

CREATE UNIQUE INDEX UX_admins_email ON dbo.admins (email);
CREATE INDEX IX_admins_location_id ON dbo.admins (location_id);
GO

CREATE TRIGGER dbo.TR_users_updated_at
ON dbo.users
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  IF TRIGGER_NESTLEVEL() > 1 RETURN;

  UPDATE target
  SET updated_at = SYSUTCDATETIME()
  FROM dbo.users AS target
  INNER JOIN inserted AS i ON i.user_id = target.user_id
  INNER JOIN deleted AS d ON d.user_id = i.user_id
  WHERE i.updated_at = d.updated_at;
END;
GO

CREATE TRIGGER dbo.TR_locations_updated_at
ON dbo.locations
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  IF TRIGGER_NESTLEVEL() > 1 RETURN;

  UPDATE target
  SET updated_at = SYSUTCDATETIME()
  FROM dbo.locations AS target
  INNER JOIN inserted AS i ON i.location_id = target.location_id
  INNER JOIN deleted AS d ON d.location_id = i.location_id
  WHERE i.updated_at = d.updated_at;
END;
GO

CREATE TRIGGER dbo.TR_visits_updated_at
ON dbo.visits
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  IF TRIGGER_NESTLEVEL() > 1 RETURN;

  UPDATE target
  SET updated_at = SYSUTCDATETIME()
  FROM dbo.visits AS target
  INNER JOIN inserted AS i ON i.visit_id = target.visit_id
  INNER JOIN deleted AS d ON d.visit_id = i.visit_id
  WHERE i.updated_at = d.updated_at;
END;
GO

CREATE TRIGGER dbo.TR_admins_updated_at
ON dbo.admins
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  IF TRIGGER_NESTLEVEL() > 1 RETURN;

  UPDATE target
  SET updated_at = SYSUTCDATETIME()
  FROM dbo.admins AS target
  INNER JOIN inserted AS i ON i.admin_id = target.admin_id
  INNER JOIN deleted AS d ON d.admin_id = i.admin_id
  WHERE i.updated_at = d.updated_at;
END;
GO

COMMIT TRANSACTION;
GO
