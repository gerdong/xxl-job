CREATE SEQUENCE xxl_job_info_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE xxl_job_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE xxl_job_log_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE xxl_job_logglue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE xxl_job_registry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE xxl_job_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE xxl_job_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

DROP TABLE IF EXISTS public.xxl_job_info;
DROP TABLE IF EXISTS public.xxl_job_lock;
DROP TABLE IF EXISTS public.xxl_job_log;
DROP TABLE IF EXISTS public.xxl_job_log_report;
DROP TABLE IF EXISTS public.xxl_job_logglue;
DROP TABLE IF EXISTS public.xxl_job_registry;
DROP TABLE IF EXISTS public.xxl_job_user;
DROP TABLE IF EXISTS public.xxl_job_group;

CREATE TABLE xxl_job_group (
    id INTEGER NOT NULL DEFAULT nextval('xxl_job_group_id_seq'::regclass),
    app_name varchar(64) NOT NULL, -- 执行器AppName
    title varchar(12) NOT NULL, -- 执行器名称
    address_type SMALLINT NOT NULL DEFAULT 0, -- 执行器地址类型：0=自动注册、1=手动录入
    address_list text NULL, -- 执行器地址列表，多地址逗号分隔
    update_time timestamp NULL,
    CONSTRAINT xxl_job_qrtz_trigger_group_pkey PRIMARY KEY (id)
);

COMMENT ON COLUMN public.xxl_job_group.app_name IS '执行器AppName';
COMMENT ON COLUMN public.xxl_job_group.title IS '执行器名称';
COMMENT ON COLUMN public.xxl_job_group.address_type IS '执行器地址类型：0=自动注册、1=手动录入';
COMMENT ON COLUMN public.xxl_job_group.address_list IS '执行器地址列表，多地址逗号分隔';

CREATE TABLE xxl_job_info (
    id INTEGER NOT NULL DEFAULT nextval('xxl_job_info_id_seq'::regclass),
    job_group INTEGER NOT NULL, -- 执行器主键ID
    job_desc varchar(255) NOT NULL, -- 任务描述
    add_time timestamp(6) NULL,
    update_time timestamp(6) NULL,
    author varchar(64) NULL, -- 作者
    alarm_email varchar(255) NULL, -- 报警邮件
    schedule_type varchar(50) NOT NULL DEFAULT 'NONE',
    schedule_conf varchar(128) DEFAULT NULL,
    misfire_strategy varchar(50) NOT NULL DEFAULT 'DO_NOTHING',
    executor_route_strategy varchar(50) NULL, -- 执行器路由策略
    executor_handler varchar(255) NULL,  -- 执行器任务handler
    executor_param varchar(512) NULL, -- 执行器任务参数
    executor_block_strategy varchar(50) NULL, -- 阻塞处理策略
    executor_timeout INTEGER NOT NULL DEFAULT 0, -- 任务执行超时时间，单位秒
    executor_fail_retry_count INTEGER NOT NULL DEFAULT 0, -- 失败重试次数
    glue_type varchar(50) NOT NULL, -- GLUE类型
    glue_source TEXT NULL, -- GLUE源代码
    glue_remark varchar(128) NULL, -- GLUE备注
    glue_updatetime timestamp(6) NULL, -- GLUE更新时间
    child_jobid varchar(255) NULL, -- 子任务ID，多个逗号分隔
    trigger_status SMALLINT NOT NULL DEFAULT 0, -- 调度状态：0-停止，1-运行
    trigger_last_time BIGINT NOT NULL DEFAULT 0, -- 上次调度时间
    trigger_next_time BIGINT NOT NULL DEFAULT 0, -- 下次调度时间
    CONSTRAINT xxl_job_info_pkey PRIMARY KEY (id)
);

COMMENT ON COLUMN public.xxl_job_info.job_group IS '执行器主键ID';
COMMENT ON COLUMN public.xxl_job_info.job_desc IS '任务描述';
COMMENT ON COLUMN public.xxl_job_info.job_desc IS '';
COMMENT ON COLUMN public.xxl_job_info.author IS '作者';
COMMENT ON COLUMN public.xxl_job_info.alarm_email IS '报警邮件';
COMMENT ON COLUMN public.xxl_job_info.schedule_type IS '调度类型';
COMMENT ON COLUMN public.xxl_job_info.schedule_conf IS '调度配置，值含义取决于调度类型';
COMMENT ON COLUMN public.xxl_job_info.misfire_strategy IS '调度过期策略';
COMMENT ON COLUMN public.xxl_job_info.executor_route_strategy IS '执行器路由策略';
COMMENT ON COLUMN public.xxl_job_info.executor_handler IS '执行器任务handler';
COMMENT ON COLUMN public.xxl_job_info.executor_param IS '执行器任务参数';
COMMENT ON COLUMN public.xxl_job_info.executor_block_strategy IS '阻塞处理策略';
COMMENT ON COLUMN public.xxl_job_info.executor_timeout IS '任务执行超时时间，单位秒';
COMMENT ON COLUMN public.xxl_job_info.glue_type IS 'GLUE类型';
COMMENT ON COLUMN public.xxl_job_info.glue_source IS 'GLUE源代码';
COMMENT ON COLUMN public.xxl_job_info.glue_remark IS 'GLUE备注';
COMMENT ON COLUMN public.xxl_job_info.glue_updatetime IS 'GLUE更新时间';
COMMENT ON COLUMN public.xxl_job_info.child_jobid IS '子任务ID，多个逗号分隔';
COMMENT ON COLUMN public.xxl_job_info.trigger_status IS '调度状态：0-停止，1-运行';
COMMENT ON COLUMN public.xxl_job_info.trigger_last_time IS '上次调度时间';
COMMENT ON COLUMN public.xxl_job_info.trigger_next_time IS '下次调度时间';
COMMENT ON COLUMN public.xxl_job_info.executor_fail_retry_count IS '失败重试次数';

CREATE TABLE xxl_job_lock (
    lock_name varchar(50) NOT NULL, -- 锁名称
    CONSTRAINT xxl_job_lock_pkey PRIMARY KEY (lock_name)
);

COMMENT ON COLUMN public.xxl_job_lock.lock_name IS '锁名称';

CREATE TABLE xxl_job_log (
    id INTEGER NOT NULL DEFAULT nextval('xxl_job_log_id_seq'::regclass),
    job_group INTEGER NOT NULL, -- 执行器主键ID
    job_id INTEGER NOT NULL, -- 任务，主键ID
    executor_address varchar(255) NULL, -- 执行器地址，本次执行的地址
    executor_handler varchar(255) NULL, -- 执行器任务handler
    executor_param varchar(512) NULL, -- 执行器任务参数
    executor_sharding_param varchar(20) NULL, -- 执行器任务分片参数，格式如 1/2
    executor_fail_retry_count INTEGER NOT NULL DEFAULT 0, -- 失败重试次数
    trigger_time timestamp(6) NULL, -- 调度-时间
    trigger_code INTEGER NOT NULL, -- 调度-结果
    trigger_msg TEXT NULL, -- 调度-日志
    handle_time timestamp(6) NULL, -- 执行-时间
    handle_code INTEGER NULL, -- 执行-状态
    handle_msg TEXT NULL, -- 执行-日志
    alarm_status SMALLINT NOT NULL DEFAULT 0, -- 告警状态：0-默认、1-无需告警、2-告警成功、3-告警失败
    CONSTRAINT xxl_job_log_pkey PRIMARY KEY (id)
);
CREATE INDEX "I_trigger_time" ON public.xxl_job_log USING btree (trigger_time);
CREATE INDEX "I_handle_code" ON public.xxl_job_log(handle_code);

COMMENT ON COLUMN public.xxl_job_log.job_group IS '执行器主键ID';
COMMENT ON COLUMN public.xxl_job_log.job_id IS '任务，主键ID';
COMMENT ON COLUMN public.xxl_job_log.executor_address IS '执行器地址，本次执行的地址';
COMMENT ON COLUMN public.xxl_job_log.executor_handler IS '执行器任务handler';
COMMENT ON COLUMN public.xxl_job_log.executor_param IS '执行器任务参数';
COMMENT ON COLUMN public.xxl_job_log.executor_sharding_param IS '执行器任务分片参数，格式如 1/2';
COMMENT ON COLUMN public.xxl_job_log.executor_fail_retry_count IS '失败重试次数';
COMMENT ON COLUMN public.xxl_job_log.trigger_time IS '调度-时间';
COMMENT ON COLUMN public.xxl_job_log.trigger_code IS '调度-结果';
COMMENT ON COLUMN public.xxl_job_log.trigger_msg IS '调度-日志';
COMMENT ON COLUMN public.xxl_job_log.handle_time IS '执行-时间';
COMMENT ON COLUMN public.xxl_job_log.handle_code IS '执行-状态';
COMMENT ON COLUMN public.xxl_job_log.handle_msg IS '执行-日志';
COMMENT ON COLUMN public.xxl_job_log.alarm_status IS '告警状态：0-默认、1-无需告警、2-告警成功、3-告警失败';


CREATE TABLE xxl_job_log_report (
    id INTEGER NOT NULL DEFAULT nextval('xxl_job_log_report_id_seq'::regclass),
    trigger_day timestamp(6) NULL, -- 调度-时间
    running_count INTEGER NOT NULL, -- 运行中-日志数量
    suc_count INTEGER NOT NULL, -- 执行成功-日志数量
    fail_count INTEGER NOT NULL DEFAULT 0, -- 执行失败-日志数量
    update_time timestamp(6) NULL DEFAULT now(),
    CONSTRAINT xxl_job_log_report_pkey PRIMARY KEY (id),
    CONSTRAINT i_trigger_day UNIQUE (trigger_day)
);

COMMENT ON COLUMN public.xxl_job_log_report.trigger_day IS '调度-时间';
COMMENT ON COLUMN public.xxl_job_log_report.running_count IS '运行中-日志数量';
COMMENT ON COLUMN public.xxl_job_log_report.suc_count IS '执行成功-日志数量';
COMMENT ON COLUMN public.xxl_job_log_report.fail_count IS '执行失败-日志数量';
COMMENT ON COLUMN public.xxl_job_log_report.update_time IS '更新时间';

CREATE TABLE xxl_job_logglue (
    id INTEGER NOT NULL DEFAULT nextval('xxl_job_logglue_id_seq'::regclass),
    job_id INTEGER NOT NULL, -- 任务，主键ID
    glue_type varchar(50) NULL, -- GLUE类型
    glue_source TEXT NULL, -- GLUE源代码
    glue_remark varchar(128) NOT NULL, -- GLUE备注
    add_time timestamp(6) NULL DEFAULT now(),
    update_time timestamp(6) NULL,
    CONSTRAINT xxl_job_logglue_pkey PRIMARY KEY (id)
);

COMMENT ON COLUMN public.xxl_job_logglue.job_id IS '任务，主键ID';
COMMENT ON COLUMN public.xxl_job_logglue.glue_type IS 'GLUE类型';
COMMENT ON COLUMN public.xxl_job_logglue.glue_source IS 'GLUE源代码';
COMMENT ON COLUMN public.xxl_job_logglue.glue_remark IS 'GLUE备注';

CREATE TABLE xxl_job_registry (
    id INTEGER NOT NULL DEFAULT nextval('xxl_job_registry_id_seq'::regclass),
    registry_group varchar(50) NOT NULL,
    registry_key varchar(255) NOT NULL,
    registry_value varchar(255) NOT NULL,
    update_time timestamp(6) NULL,
    CONSTRAINT xxl_job_registry_pkey PRIMARY KEY (id)
);
CREATE INDEX "i_g_k_v" ON public.xxl_job_registry(registry_group, registry_key, registry_value);


CREATE TABLE xxl_job_user (
    id INTEGER NOT NULL DEFAULT nextval('xxl_job_user_id_seq'::regclass),
    username varchar(50) NOT NULL, -- 账号
    "password" varchar(50) NOT NULL, -- 密码
    "role" SMALLINT NOT NULL, -- 角色：0-普通用户、1-管理员
    "permission" varchar(255) NULL, -- 权限：执行器ID列表，多个逗号分割
    CONSTRAINT xxl_job_user_pkey PRIMARY KEY (id),
    CONSTRAINT i_username UNIQUE (username)
);

COMMENT ON COLUMN public.xxl_job_user.username IS '账号';
COMMENT ON COLUMN public.xxl_job_user."password" IS '密码';
COMMENT ON COLUMN public.xxl_job_user."role" IS '角色：0-普通用户、1-管理员';
COMMENT ON COLUMN public.xxl_job_user."permission" IS '权限：执行器ID列表，多个逗号分割';

INSERT INTO public.xxl_job_group ( app_name, title, address_type, address_list, update_time) values ( 'xxl-job-executor-sample', '示例执行器', '1', null, now());
INSERT INTO public.xxl_job_user( username, password, role, permission) VALUES ( 'admin', 'e10adc3949ba59abbe56e057f20f883e', 1, NULL);
