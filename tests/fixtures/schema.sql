
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

CREATE TABLE public.activity_log (
    id bigint NOT NULL,
    log_name character varying(255),
    description text NOT NULL,
    subject_type character varying(255),
    subject_id bigint,
    causer_type character varying(255),
    causer_id bigint,
    properties jsonb,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    event character varying(255),
    batch_uuid uuid
);

CREATE SEQUENCE public.activity_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.activity_log_id_seq OWNED BY public.activity_log.id;

CREATE TABLE public.additional_destinations (
    id bigint NOT NULL,
    application_id bigint NOT NULL,
    server_id bigint NOT NULL,
    status character varying(255) DEFAULT 'exited'::character varying NOT NULL,
    standalone_docker_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);

CREATE SEQUENCE public.additional_destinations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.additional_destinations_id_seq OWNED BY public.additional_destinations.id;

CREATE TABLE public.application_deployment_queues (
    id bigint NOT NULL,
    application_id character varying(255) NOT NULL,
    deployment_uuid character varying(255) NOT NULL,
    pull_request_id integer DEFAULT 0 NOT NULL,
    force_rebuild boolean DEFAULT false NOT NULL,
    commit character varying(255) DEFAULT 'HEAD'::character varying NOT NULL,
    status character varying(255) DEFAULT 'queued'::character varying NOT NULL,
    is_webhook boolean DEFAULT false NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    logs text,
    current_process_id character varying(255),
    restart_only boolean DEFAULT false NOT NULL,
    git_type character varying(255),
    server_id integer,
    application_name character varying(255),
    server_name character varying(255),
    deployment_url character varying(255),
    destination_id character varying(255),
    only_this_server boolean DEFAULT false NOT NULL,
    rollback boolean DEFAULT false NOT NULL,
    commit_message text,
    is_api boolean DEFAULT false NOT NULL,
    build_server_id integer,
    horizon_job_id character varying(255),
    horizon_job_worker character varying(255),
    finished_at timestamp(0) without time zone,
    docker_registry_image_tag character varying(255),
    configuration_hash character varying(255),
    configuration_snapshot text,
    configuration_diff text,
    parent_deployment_uuid character varying(255)
)
WITH (fillfactor='90');

CREATE SEQUENCE public.application_deployment_queues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.application_deployment_queues_id_seq OWNED BY public.application_deployment_queues.id;

CREATE TABLE public.application_previews (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    pull_request_id integer NOT NULL,
    pull_request_html_url character varying(255) NOT NULL,
    pull_request_issue_comment_id character varying(255),
    fqdn text,
    status character varying(255) DEFAULT 'exited'::character varying NOT NULL,
    application_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    git_type character varying(255),
    docker_compose_domains text,
    last_online_at timestamp(0) without time zone DEFAULT '2024-11-14 12:28:18'::timestamp without time zone NOT NULL,
    deleted_at timestamp(0) without time zone,
    docker_registry_image_tag character varying(255),
    domain_dns_statuses json,
    restart_count integer DEFAULT 0 NOT NULL,
    max_restart_count integer DEFAULT 0 NOT NULL,
    restart_limit_reached boolean DEFAULT false NOT NULL,
    last_restart_at timestamp(0) without time zone,
    last_restart_type character varying(10),
    domain_port_overrides json,
    keeps_production_values boolean DEFAULT false NOT NULL
);

CREATE SEQUENCE public.application_previews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.application_previews_id_seq OWNED BY public.application_previews.id;

CREATE TABLE public.application_settings (
    id bigint NOT NULL,
    is_static boolean DEFAULT false NOT NULL,
    is_git_submodules_enabled boolean DEFAULT true NOT NULL,
    is_git_lfs_enabled boolean DEFAULT true NOT NULL,
    is_auto_deploy_enabled boolean DEFAULT true NOT NULL,
    is_force_https_enabled boolean DEFAULT true NOT NULL,
    is_debug_enabled boolean DEFAULT false NOT NULL,
    is_preview_deployments_enabled boolean DEFAULT false NOT NULL,
    application_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    is_log_drain_enabled boolean DEFAULT false NOT NULL,
    is_gpu_enabled boolean DEFAULT false NOT NULL,
    gpu_driver character varying(255) DEFAULT 'nvidia'::character varying NOT NULL,
    gpu_count character varying(255),
    gpu_device_ids character varying(255),
    gpu_options text,
    is_include_timestamps boolean DEFAULT false NOT NULL,
    is_swarm_only_worker_nodes boolean DEFAULT true NOT NULL,
    is_raw_compose_deployment_enabled boolean DEFAULT false NOT NULL,
    is_build_server_enabled boolean DEFAULT false NOT NULL,
    is_consistent_container_name_enabled boolean DEFAULT false NOT NULL,
    is_gzip_enabled boolean DEFAULT true NOT NULL,
    is_stripprefix_enabled boolean DEFAULT true NOT NULL,
    connect_to_docker_network boolean DEFAULT false NOT NULL,
    custom_internal_name character varying(255),
    is_container_label_escape_enabled boolean DEFAULT true NOT NULL,
    is_env_sorting_enabled boolean DEFAULT false NOT NULL,
    is_container_label_readonly_enabled boolean DEFAULT true NOT NULL,
    is_preserve_repository_enabled boolean DEFAULT false NOT NULL,
    disable_build_cache boolean DEFAULT false NOT NULL,
    is_spa boolean DEFAULT false NOT NULL,
    is_git_shallow_clone_enabled boolean DEFAULT true NOT NULL,
    is_pr_deployments_public_enabled boolean DEFAULT false NOT NULL,
    use_build_secrets boolean DEFAULT false NOT NULL,
    inject_build_args_to_dockerfile boolean DEFAULT true NOT NULL,
    include_source_commit_in_build boolean DEFAULT false NOT NULL,
    docker_images_to_keep integer DEFAULT 2 NOT NULL,
    stop_grace_period integer,
    custom_container_name_prefix character varying(255),
    redact_all_env_values_in_logs boolean DEFAULT true NOT NULL,
    traefik_certificate_resolver character varying(255),
    include_coolify_default_variables boolean DEFAULT true NOT NULL,
    is_permanent_redirect_enabled boolean DEFAULT false NOT NULL,
    rolling_update_drain_seconds integer DEFAULT 5 NOT NULL
);

CREATE SEQUENCE public.application_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.application_settings_id_seq OWNED BY public.application_settings.id;

CREATE TABLE public.applications (
    id bigint NOT NULL,
    repository_project_id integer,
    uuid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    fqdn text,
    config_hash character varying(255),
    git_repository character varying(255) NOT NULL,
    git_branch character varying(255) NOT NULL,
    git_commit_sha character varying(255) DEFAULT 'HEAD'::character varying NOT NULL,
    git_full_url character varying(255),
    docker_registry_image_name character varying(255),
    docker_registry_image_tag character varying(255),
    build_pack character varying(255) NOT NULL,
    static_image character varying(255) DEFAULT 'nginx:alpine'::character varying NOT NULL,
    install_command character varying(255),
    build_command character varying(255),
    start_command character varying(255),
    ports_exposes character varying(255),
    ports_mappings character varying(255),
    base_directory character varying(255) DEFAULT '/'::character varying NOT NULL,
    publish_directory character varying(255),
    health_check_path character varying(255) DEFAULT '/'::character varying NOT NULL,
    health_check_port character varying(255),
    health_check_host character varying(255) DEFAULT 'localhost'::character varying NOT NULL,
    health_check_method character varying(255) DEFAULT 'GET'::character varying NOT NULL,
    health_check_return_code integer DEFAULT 200 NOT NULL,
    health_check_scheme character varying(255) DEFAULT 'http'::character varying NOT NULL,
    health_check_response_text character varying(255),
    health_check_interval integer DEFAULT 5 NOT NULL,
    health_check_timeout integer DEFAULT 5 NOT NULL,
    health_check_retries integer DEFAULT 10 NOT NULL,
    health_check_start_period integer DEFAULT 5 NOT NULL,
    limits_memory character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_memory_swap character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_memory_swappiness integer DEFAULT 60 NOT NULL,
    limits_memory_reservation character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_cpus character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_cpuset character varying(255),
    limits_cpu_shares integer DEFAULT 1024 NOT NULL,
    status character varying(255) DEFAULT 'exited'::character varying NOT NULL,
    preview_url_template character varying(255) DEFAULT '{{pr_id}}.{{domain}}'::character varying NOT NULL,
    destination_type character varying(255),
    destination_id bigint,
    source_type character varying(255),
    source_id bigint,
    private_key_id bigint,
    environment_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    description character varying(255),
    dockerfile text,
    health_check_enabled boolean DEFAULT false NOT NULL,
    dockerfile_location character varying(255),
    custom_labels text,
    dockerfile_target_build character varying(255),
    manual_webhook_secret_github text,
    manual_webhook_secret_gitlab text,
    docker_compose_location character varying(255) DEFAULT '/docker-compose.yaml'::character varying,
    docker_compose text,
    docker_compose_raw text,
    docker_compose_domains text,
    deleted_at timestamp(0) without time zone,
    docker_compose_custom_start_command character varying(255),
    docker_compose_custom_build_command character varying(255),
    swarm_replicas integer DEFAULT 1 NOT NULL,
    swarm_placement_constraints text,
    manual_webhook_secret_bitbucket text,
    custom_docker_run_options text,
    post_deployment_command text,
    post_deployment_command_container character varying(255),
    pre_deployment_command text,
    pre_deployment_command_container character varying(255),
    watch_paths text,
    custom_healthcheck_found boolean DEFAULT false NOT NULL,
    manual_webhook_secret_gitea text,
    redirect character varying(255) DEFAULT 'both'::character varying NOT NULL,
    compose_parsing_version character varying(255) DEFAULT '1'::character varying NOT NULL,
    last_online_at timestamp(0) without time zone DEFAULT '2024-11-14 12:28:18'::timestamp without time zone NOT NULL,
    custom_nginx_configuration text,
    custom_network_aliases text,
    is_http_basic_auth_enabled boolean DEFAULT false NOT NULL,
    http_basic_auth_username character varying(255),
    http_basic_auth_password character varying(255),
    restart_count integer DEFAULT 0 NOT NULL,
    last_restart_at timestamp(0) without time zone,
    last_restart_type character varying(10),
    health_check_type text DEFAULT 'http'::text NOT NULL,
    health_check_command text,
    max_restart_count integer DEFAULT 0 NOT NULL,
    noindex_domains json,
    domain_dns_statuses json,
    container_present boolean,
    restart_limit_reached boolean DEFAULT false NOT NULL,
    domain_port_overrides json,
    is_maintenance_enabled boolean DEFAULT false NOT NULL,
    maintenance_page text,
    http_basic_auth_hash_algorithm character varying(255) DEFAULT 'bcrypt'::character varying NOT NULL,
    http_basic_auth_bcrypt_cost smallint DEFAULT '10'::smallint NOT NULL,
    http_basic_auth_argon2id_memory_cost integer DEFAULT 65536 NOT NULL,
    http_basic_auth_argon2id_time_cost smallint DEFAULT '4'::smallint NOT NULL,
    git_https_username character varying(255),
    git_https_password text
)
WITH (fillfactor='70', autovacuum_vacuum_scale_factor='0.05');

CREATE SEQUENCE public.applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.applications_id_seq OWNED BY public.applications.id;

CREATE TABLE public.audit_events (
    id bigint NOT NULL,
    team_id bigint,
    event character varying(255) NOT NULL,
    source character varying(32) NOT NULL,
    action character varying(64) NOT NULL,
    actor_type character varying(32) NOT NULL,
    actor_id bigint,
    actor_name character varying(255),
    actor_email character varying(255),
    actor_token_id bigint,
    actor_token_name character varying(255),
    resource_type character varying(255),
    resource_uuid character varying(255),
    resource_name character varying(255),
    description text NOT NULL,
    metadata json,
    ip_address character varying(45),
    user_agent character varying(200),
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    changes text,
    level character varying(16) DEFAULT 'info'::character varying NOT NULL
);

CREATE SEQUENCE public.audit_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.audit_events_id_seq OWNED BY public.audit_events.id;

CREATE TABLE public.cloud_init_scripts (
    id bigint NOT NULL,
    team_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    script text NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    uuid character varying(255)
);

CREATE SEQUENCE public.cloud_init_scripts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.cloud_init_scripts_id_seq OWNED BY public.cloud_init_scripts.id;

CREATE TABLE public.cloud_provider_tokens (
    id bigint NOT NULL,
    team_id bigint NOT NULL,
    provider character varying(255) NOT NULL,
    token text NOT NULL,
    name character varying(255),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    uuid character varying(255) NOT NULL,
    description text
);

CREATE SEQUENCE public.cloud_provider_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.cloud_provider_tokens_id_seq OWNED BY public.cloud_provider_tokens.id;

CREATE TABLE public.database_backup_s3_replicas (
    id bigint NOT NULL,
    execution_id bigint NOT NULL,
    s3_storage_id bigint,
    s3_uploaded boolean,
    s3_storage_deleted boolean DEFAULT false NOT NULL,
    message text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);

CREATE SEQUENCE public.database_backup_s3_replicas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.database_backup_s3_replicas_id_seq OWNED BY public.database_backup_s3_replicas.id;

CREATE TABLE public.discord_notification_settings (
    id bigint NOT NULL,
    team_id bigint NOT NULL,
    discord_enabled boolean DEFAULT false NOT NULL,
    discord_webhook_url text,
    deployment_success_discord_notifications boolean DEFAULT false NOT NULL,
    deployment_failure_discord_notifications boolean DEFAULT true NOT NULL,
    status_change_discord_notifications boolean DEFAULT false NOT NULL,
    backup_success_discord_notifications boolean DEFAULT false NOT NULL,
    backup_failure_discord_notifications boolean DEFAULT true NOT NULL,
    scheduled_task_success_discord_notifications boolean DEFAULT false NOT NULL,
    scheduled_task_failure_discord_notifications boolean DEFAULT true NOT NULL,
    docker_cleanup_success_discord_notifications boolean DEFAULT false NOT NULL,
    docker_cleanup_failure_discord_notifications boolean DEFAULT true NOT NULL,
    server_disk_usage_discord_notifications boolean DEFAULT true NOT NULL,
    server_reachable_discord_notifications boolean DEFAULT false NOT NULL,
    server_unreachable_discord_notifications boolean DEFAULT true NOT NULL,
    discord_ping_enabled boolean DEFAULT true NOT NULL,
    server_patch_discord_notifications boolean DEFAULT true NOT NULL,
    traefik_outdated_discord_notifications boolean DEFAULT true NOT NULL,
    restart_limit_reached_discord_notifications boolean DEFAULT true NOT NULL,
    failure_count integer DEFAULT 0 NOT NULL
);

CREATE SEQUENCE public.discord_notification_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.discord_notification_settings_id_seq OWNED BY public.discord_notification_settings.id;

CREATE TABLE public.dns_provider_zones (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    integration_token_id bigint NOT NULL,
    provider_zone_id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    account_id character varying(255),
    account_name character varying(255),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);

CREATE SEQUENCE public.dns_provider_zones_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.dns_provider_zones_id_seq OWNED BY public.dns_provider_zones.id;

CREATE TABLE public.docker_cleanup_executions (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    status character varying(255) DEFAULT 'running'::character varying NOT NULL,
    message text,
    cleanup_log json,
    server_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    finished_at timestamp(0) without time zone,
    CONSTRAINT docker_cleanup_executions_status_check CHECK (((status)::text = ANY (ARRAY[('success'::character varying)::text, ('failed'::character varying)::text, ('running'::character varying)::text])))
);

CREATE SEQUENCE public.docker_cleanup_executions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.docker_cleanup_executions_id_seq OWNED BY public.docker_cleanup_executions.id;

CREATE TABLE public.email_notification_settings (
    id bigint NOT NULL,
    team_id bigint NOT NULL,
    smtp_enabled boolean DEFAULT false NOT NULL,
    smtp_from_address text,
    smtp_from_name text,
    smtp_recipients text,
    smtp_host text,
    smtp_port integer,
    smtp_encryption character varying(255),
    smtp_username text,
    smtp_password text,
    smtp_timeout integer,
    resend_enabled boolean DEFAULT false NOT NULL,
    resend_api_key text,
    use_instance_email_settings boolean DEFAULT false NOT NULL,
    deployment_success_email_notifications boolean DEFAULT false NOT NULL,
    deployment_failure_email_notifications boolean DEFAULT true NOT NULL,
    status_change_email_notifications boolean DEFAULT false NOT NULL,
    backup_success_email_notifications boolean DEFAULT false NOT NULL,
    backup_failure_email_notifications boolean DEFAULT true NOT NULL,
    scheduled_task_success_email_notifications boolean DEFAULT false NOT NULL,
    scheduled_task_failure_email_notifications boolean DEFAULT true NOT NULL,
    docker_cleanup_success_email_notifications boolean DEFAULT false NOT NULL,
    docker_cleanup_failure_email_notifications boolean DEFAULT true NOT NULL,
    server_disk_usage_email_notifications boolean DEFAULT true NOT NULL,
    server_reachable_email_notifications boolean DEFAULT false NOT NULL,
    server_unreachable_email_notifications boolean DEFAULT true NOT NULL,
    server_patch_email_notifications boolean DEFAULT true NOT NULL,
    traefik_outdated_email_notifications boolean DEFAULT true NOT NULL,
    smtp_ehlo_domain character varying(255),
    restart_limit_reached_email_notifications boolean DEFAULT true NOT NULL,
    failure_count integer DEFAULT 0 NOT NULL,
    deployment_commit_details_email_notifications boolean DEFAULT false NOT NULL
);

CREATE SEQUENCE public.email_notification_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.email_notification_settings_id_seq OWNED BY public.email_notification_settings.id;

CREATE TABLE public.environment_variables (
    id bigint NOT NULL,
    key character varying(255) NOT NULL,
    value text,
    is_preview boolean DEFAULT false NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    is_shown_once boolean DEFAULT false NOT NULL,
    is_multiline boolean DEFAULT false NOT NULL,
    version character varying(255) DEFAULT '4.0.0-beta.239'::character varying NOT NULL,
    is_literal boolean DEFAULT false NOT NULL,
    uuid character varying(255) NOT NULL,
    "order" integer,
    is_required boolean DEFAULT false NOT NULL,
    is_shared boolean DEFAULT false NOT NULL,
    resourceable_type character varying(255),
    resourceable_id bigint,
    is_runtime boolean DEFAULT true NOT NULL,
    is_buildtime boolean DEFAULT true NOT NULL,
    comment character varying(256),
    uses_legacy_escaping boolean DEFAULT false NOT NULL,
    preserve_compose_null boolean DEFAULT false NOT NULL
);

CREATE SEQUENCE public.environment_variables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.environment_variables_id_seq OWNED BY public.environment_variables.id;

CREATE TABLE public.environments (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    project_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    description character varying(255),
    uuid character varying(255) NOT NULL,
    canvas_positions json
);

CREATE SEQUENCE public.environments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.environments_id_seq OWNED BY public.environments.id;

CREATE TABLE public.failed_jobs (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    connection text NOT NULL,
    queue text NOT NULL,
    payload text NOT NULL,
    exception text NOT NULL,
    failed_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE SEQUENCE public.failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.failed_jobs_id_seq OWNED BY public.failed_jobs.id;

CREATE TABLE public.gitea_apps (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    organization character varying(255),
    api_url character varying(255) NOT NULL,
    html_url character varying(255) NOT NULL,
    custom_port integer DEFAULT 22 NOT NULL,
    custom_user character varying(255) DEFAULT 'git'::character varying NOT NULL,
    is_system_wide boolean DEFAULT false NOT NULL,
    is_public boolean DEFAULT false NOT NULL,
    client_id text,
    client_secret text,
    access_token text,
    refresh_token text,
    expires_at integer,
    redirect_uri character varying(255),
    webhook_secret text,
    private_key_id bigint,
    team_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);

CREATE SEQUENCE public.gitea_apps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.gitea_apps_id_seq OWNED BY public.gitea_apps.id;

CREATE TABLE public.github_apps (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    organization character varying(255),
    api_url character varying(255) NOT NULL,
    html_url character varying(255) NOT NULL,
    custom_user character varying(255) DEFAULT 'git'::character varying NOT NULL,
    custom_port integer DEFAULT 22 NOT NULL,
    app_id integer,
    installation_id integer,
    client_id character varying(255),
    client_secret text,
    webhook_secret text,
    is_system_wide boolean DEFAULT false NOT NULL,
    is_public boolean DEFAULT false NOT NULL,
    private_key_id bigint,
    team_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    contents character varying(255),
    metadata character varying(255),
    pull_requests character varying(255),
    administration character varying(255),
    organization_self_hosted_runners character varying(255),
    actions character varying(255),
    webhook_events json,
    runner_group_id bigint
);

CREATE SEQUENCE public.github_apps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.github_apps_id_seq OWNED BY public.github_apps.id;

CREATE TABLE public.github_runner_configs (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    server_id bigint NOT NULL,
    github_app_id bigint NOT NULL,
    labels json NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    is_dedicated boolean DEFAULT false NOT NULL,
    max_runners smallint DEFAULT '2'::smallint NOT NULL,
    docker_mode character varying(255) DEFAULT 'none'::character varying NOT NULL,
    runner_image character varying(255),
    cpu_limit character varying(255),
    memory_limit character varying(255),
    capacity_wait_timeout integer DEFAULT 60 NOT NULL,
    idle_timeout integer DEFAULT 10 NOT NULL,
    job_timeout integer DEFAULT 360 NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    allow_pull_requests boolean DEFAULT false NOT NULL
);

CREATE SEQUENCE public.github_runner_configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.github_runner_configs_id_seq OWNED BY public.github_runner_configs.id;

CREATE TABLE public.github_runner_executions (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    github_app_id bigint NOT NULL,
    github_runner_config_id bigint,
    server_id bigint,
    status character varying(255) DEFAULT 'queued'::character varying NOT NULL,
    trigger_workflow_job_id bigint NOT NULL,
    workflow_job_id bigint,
    workflow_job_html_url character varying(255),
    workflow_name character varying(255),
    job_name character varying(255),
    repository_full_name character varying(255),
    labels json,
    runner_name character varying(255),
    runner_id bigint,
    conclusion character varying(255),
    error_message text,
    provision_attempts smallint DEFAULT '0'::smallint NOT NULL,
    queued_at timestamp(0) without time zone,
    ready_at timestamp(0) without time zone,
    started_at timestamp(0) without time zone,
    completed_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    is_pull_request boolean DEFAULT false NOT NULL
);

CREATE SEQUENCE public.github_runner_executions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.github_runner_executions_id_seq OWNED BY public.github_runner_executions.id;

CREATE TABLE public.gitlab_apps (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    organization character varying(255),
    api_url character varying(255) NOT NULL,
    html_url character varying(255) NOT NULL,
    custom_port integer DEFAULT 22 NOT NULL,
    custom_user character varying(255) DEFAULT 'git'::character varying NOT NULL,
    is_system_wide boolean DEFAULT false NOT NULL,
    is_public boolean DEFAULT false NOT NULL,
    app_id integer,
    app_secret text,
    oauth_id integer,
    group_name character varying(255),
    public_key text,
    webhook_token text,
    deploy_key_id integer,
    private_key_id bigint,
    team_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    client_id text,
    client_secret text,
    access_token text,
    refresh_token text,
    expires_at integer,
    redirect_uri character varying(255)
);

CREATE SEQUENCE public.gitlab_apps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.gitlab_apps_id_seq OWNED BY public.gitlab_apps.id;

CREATE TABLE public.instance_settings (
    id bigint NOT NULL,
    public_ipv4 character varying(255),
    public_ipv6 character varying(255),
    fqdn character varying(255),
    public_port_min integer DEFAULT 9000 NOT NULL,
    public_port_max integer DEFAULT 9100 NOT NULL,
    do_not_track boolean DEFAULT false NOT NULL,
    is_auto_update_enabled boolean DEFAULT true NOT NULL,
    is_registration_enabled boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    next_channel boolean DEFAULT false NOT NULL,
    smtp_enabled boolean DEFAULT false NOT NULL,
    smtp_from_address text,
    smtp_from_name text,
    smtp_recipients text,
    smtp_host text,
    smtp_port integer,
    smtp_encryption character varying(255),
    smtp_username text,
    smtp_password text,
    smtp_timeout integer,
    resend_enabled boolean DEFAULT false NOT NULL,
    resend_api_key text,
    is_dns_validation_enabled boolean DEFAULT true NOT NULL,
    custom_dns_servers character varying(255) DEFAULT '1.1.1.1'::character varying,
    instance_name character varying(255),
    is_api_enabled boolean DEFAULT false NOT NULL,
    allowed_ips text,
    auto_update_frequency character varying(255) DEFAULT '0 0 * * *'::character varying NOT NULL,
    update_check_frequency character varying(255) DEFAULT '0 * * * *'::character varying NOT NULL,
    new_version_available boolean DEFAULT false NOT NULL,
    instance_timezone character varying(255) DEFAULT 'UTC'::character varying NOT NULL,
    helper_version character varying(255) DEFAULT '1.0.0'::character varying NOT NULL,
    disable_two_step_confirmation boolean DEFAULT false NOT NULL,
    is_sponsorship_popup_enabled boolean DEFAULT true NOT NULL,
    dev_helper_version character varying(255),
    is_wire_navigate_enabled boolean DEFAULT true NOT NULL,
    is_mcp_server_enabled boolean DEFAULT false NOT NULL,
    docker_registry_url character varying(255) DEFAULT 'docker.io'::character varying NOT NULL,
    webhook_allowed_internal_hosts json,
    webhook_allow_localhost boolean DEFAULT false NOT NULL,
    domain_connect_private_key text,
    avatar_storage_type character varying(255) DEFAULT 'local'::character varying NOT NULL,
    avatar_s3_storage_id bigint,
    is_dashboard_force_https_enabled boolean DEFAULT true NOT NULL,
    smtp_ehlo_domain character varying(255),
    image_cdn_url character varying(255),
    disable_registration_when_oauth_enabled boolean DEFAULT false NOT NULL,
    is_backup_before_update_enabled boolean DEFAULT true NOT NULL,
    is_passkey_enabled boolean DEFAULT true NOT NULL,
    file_download_s3_storage_id bigint,
    server_validation_rate_limit_seconds integer DEFAULT 600 NOT NULL,
    server_validation_max_failures_per_ip integer DEFAULT 10 NOT NULL,
    server_validation_max_failures_per_team integer DEFAULT 30 NOT NULL,
    update_channel character varying(255) DEFAULT 'stable'::character varying NOT NULL,
    update_custom_tag character varying(255),
    previous_update_channel character varying(255)
);

CREATE SEQUENCE public.instance_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.instance_settings_id_seq OWNED BY public.instance_settings.id;

CREATE TABLE public.integration_tokens (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    team_id bigint NOT NULL,
    provider character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    token text NOT NULL,
    capabilities json NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    metadata json
);

CREATE SEQUENCE public.integration_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.integration_tokens_id_seq OWNED BY public.integration_tokens.id;

CREATE TABLE public.local_file_volumes (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    fs_path text NOT NULL,
    mount_path text,
    content text,
    resource_type character varying(255),
    resource_id bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    is_directory boolean DEFAULT false NOT NULL,
    chown character varying(255),
    chmod character varying(255),
    is_based_on_git boolean DEFAULT false NOT NULL,
    is_preview_suffix_enabled boolean DEFAULT true NOT NULL,
    is_host_file boolean DEFAULT false NOT NULL
);

CREATE SEQUENCE public.local_file_volumes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.local_file_volumes_id_seq OWNED BY public.local_file_volumes.id;

CREATE TABLE public.local_persistent_volumes (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    mount_path character varying(255) NOT NULL,
    host_path character varying(255),
    container_id character varying(255),
    resource_type character varying(255),
    resource_id bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    is_preview_suffix_enabled boolean DEFAULT true NOT NULL,
    uuid character varying(255) NOT NULL,
    standalone_sqlite_id bigint,
    ignores_compose_driver_options boolean DEFAULT false NOT NULL
);

CREATE SEQUENCE public.local_persistent_volumes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.local_persistent_volumes_id_seq OWNED BY public.local_persistent_volumes.id;

CREATE TABLE public.managed_dns_record_references (
    id bigint NOT NULL,
    managed_dns_record_id bigint NOT NULL,
    resource_type character varying(255) NOT NULL,
    resource_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);

CREATE SEQUENCE public.managed_dns_record_references_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.managed_dns_record_references_id_seq OWNED BY public.managed_dns_record_references.id;

CREATE TABLE public.managed_dns_records (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    team_id bigint NOT NULL,
    integration_token_id bigint NOT NULL,
    dns_provider_zone_id bigint NOT NULL,
    provider_record_id character varying(255) NOT NULL,
    type character varying(16) NOT NULL,
    name character varying(255) NOT NULL,
    content character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    owned boolean DEFAULT false NOT NULL
);

CREATE SEQUENCE public.managed_dns_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.managed_dns_records_id_seq OWNED BY public.managed_dns_records.id;

CREATE TABLE public.migrations (
    id integer NOT NULL,
    migration character varying(255) NOT NULL,
    batch integer NOT NULL
);

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;

CREATE TABLE public.notification_throttles (
    id bigint NOT NULL,
    notifiable_type character varying(255) NOT NULL,
    notifiable_id bigint NOT NULL,
    notification character varying(255) NOT NULL,
    sent_at timestamp(0) with time zone NOT NULL
);

CREATE SEQUENCE public.notification_throttles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.notification_throttles_id_seq OWNED BY public.notification_throttles.id;

CREATE TABLE public.oauth_identities (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    provider character varying(255) NOT NULL,
    issuer character varying(255) NOT NULL,
    provider_user_id character varying(255) NOT NULL,
    email character varying(255),
    raw_claims json,
    last_login_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);

CREATE SEQUENCE public.oauth_identities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.oauth_identities_id_seq OWNED BY public.oauth_identities.id;

CREATE TABLE public.oauth_settings (
    id bigint NOT NULL,
    provider character varying(255) NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    client_id character varying(255),
    client_secret text,
    redirect_uri character varying(255),
    tenant character varying(255),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    base_url character varying(255),
    custom_label character varying(255),
    scopes character varying(255),
    allow_registration boolean DEFAULT true NOT NULL,
    require_email_verified boolean DEFAULT true NOT NULL,
    use_pkce boolean DEFAULT true NOT NULL,
    clock_skew_seconds smallint DEFAULT '60'::smallint NOT NULL,
    auto_join_root_team boolean DEFAULT false NOT NULL
);

CREATE SEQUENCE public.oauth_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.oauth_settings_id_seq OWNED BY public.oauth_settings.id;

CREATE TABLE public.passkeys (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    credential_id character varying(255) NOT NULL,
    credential json NOT NULL,
    last_used_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);

CREATE SEQUENCE public.passkeys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.passkeys_id_seq OWNED BY public.passkeys.id;

CREATE TABLE public.password_reset_tokens (
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp(0) without time zone
);

CREATE TABLE public.personal_access_tokens (
    id bigint NOT NULL,
    tokenable_type character varying(255) NOT NULL,
    tokenable_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    token character varying(64) NOT NULL,
    team_id character varying(255) NOT NULL,
    abilities text,
    last_used_at timestamp(0) without time zone,
    expires_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    api_token_expiration_warning_sent_at timestamp(0) without time zone,
    scopes json,
    paused_at timestamp(0) without time zone
);

CREATE SEQUENCE public.personal_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.personal_access_tokens_id_seq OWNED BY public.personal_access_tokens.id;

CREATE TABLE public.private_keys (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255),
    private_key text NOT NULL,
    is_git_related boolean DEFAULT false NOT NULL,
    team_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    fingerprint character varying(255)
);

CREATE SEQUENCE public.private_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.private_keys_id_seq OWNED BY public.private_keys.id;

CREATE TABLE public.project_settings (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);

CREATE SEQUENCE public.project_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.project_settings_id_seq OWNED BY public.project_settings.id;

CREATE TABLE public.projects (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255),
    team_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    icon_path character varying(255),
    icon_storage_type character varying(255),
    icon_s3_storage_id bigint,
    canvas_position json
);

CREATE SEQUENCE public.projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.projects_id_seq OWNED BY public.projects.id;

CREATE TABLE public.pushover_notification_settings (
    id bigint NOT NULL,
    team_id bigint NOT NULL,
    pushover_enabled boolean DEFAULT false NOT NULL,
    pushover_user_key text,
    pushover_api_token text,
    deployment_success_pushover_notifications boolean DEFAULT false NOT NULL,
    deployment_failure_pushover_notifications boolean DEFAULT true NOT NULL,
    status_change_pushover_notifications boolean DEFAULT false NOT NULL,
    backup_success_pushover_notifications boolean DEFAULT false NOT NULL,
    backup_failure_pushover_notifications boolean DEFAULT true NOT NULL,
    scheduled_task_success_pushover_notifications boolean DEFAULT false NOT NULL,
    scheduled_task_failure_pushover_notifications boolean DEFAULT true NOT NULL,
    docker_cleanup_success_pushover_notifications boolean DEFAULT false NOT NULL,
    docker_cleanup_failure_pushover_notifications boolean DEFAULT true NOT NULL,
    server_disk_usage_pushover_notifications boolean DEFAULT true NOT NULL,
    server_reachable_pushover_notifications boolean DEFAULT false NOT NULL,
    server_unreachable_pushover_notifications boolean DEFAULT true NOT NULL,
    server_patch_pushover_notifications boolean DEFAULT true NOT NULL,
    traefik_outdated_pushover_notifications boolean DEFAULT true NOT NULL,
    restart_limit_reached_pushover_notifications boolean DEFAULT true NOT NULL,
    failure_count integer DEFAULT 0 NOT NULL
);

CREATE SEQUENCE public.pushover_notification_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.pushover_notification_settings_id_seq OWNED BY public.pushover_notification_settings.id;

CREATE TABLE public.resource_links (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    environment_id bigint NOT NULL,
    source_type character varying(255) NOT NULL,
    source_id bigint NOT NULL,
    target_type character varying(255) NOT NULL,
    target_id bigint NOT NULL,
    label character varying(64),
    created_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);

CREATE SEQUENCE public.resource_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.resource_links_id_seq OWNED BY public.resource_links.id;

CREATE TABLE public.s3_storages (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    region character varying(255) DEFAULT 'us-east-1'::character varying NOT NULL,
    key text NOT NULL,
    secret text NOT NULL,
    bucket text NOT NULL,
    endpoint text,
    team_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    is_usable boolean DEFAULT false NOT NULL,
    unusable_email_sent boolean DEFAULT false NOT NULL,
    use_path_style_endpoint boolean DEFAULT true NOT NULL
);

CREATE SEQUENCE public.s3_storages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.s3_storages_id_seq OWNED BY public.s3_storages.id;

CREATE TABLE public.scheduled_database_backup_executions (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    status character varying(255) DEFAULT 'running'::character varying NOT NULL,
    message text,
    size text,
    filename text,
    scheduled_database_backup_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    database_name character varying(255),
    finished_at timestamp(0) without time zone,
    local_storage_deleted boolean DEFAULT false NOT NULL,
    s3_storage_deleted boolean DEFAULT false NOT NULL,
    s3_uploaded boolean,
    worker_host character varying(255),
    CONSTRAINT scheduled_database_backup_executions_status_check CHECK (((status)::text = ANY (ARRAY[('success'::character varying)::text, ('failed'::character varying)::text, ('running'::character varying)::text])))
);

CREATE SEQUENCE public.scheduled_database_backup_executions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.scheduled_database_backup_executions_id_seq OWNED BY public.scheduled_database_backup_executions.id;

CREATE TABLE public.scheduled_database_backup_s3_storage (
    id bigint NOT NULL,
    scheduled_database_backup_id bigint NOT NULL,
    s3_storage_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);

CREATE SEQUENCE public.scheduled_database_backup_s3_storage_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.scheduled_database_backup_s3_storage_id_seq OWNED BY public.scheduled_database_backup_s3_storage.id;

CREATE TABLE public.scheduled_database_backups (
    id bigint NOT NULL,
    description text,
    uuid character varying(255) NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    save_s3 boolean DEFAULT true NOT NULL,
    frequency character varying(255) NOT NULL,
    database_backup_retention_amount_locally integer DEFAULT 0 NOT NULL,
    database_type character varying(255) NOT NULL,
    database_id bigint NOT NULL,
    s3_storage_id bigint,
    team_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    databases_to_backup text,
    dump_all boolean DEFAULT false NOT NULL,
    database_backup_retention_days_locally integer DEFAULT 0 NOT NULL,
    database_backup_retention_max_storage_locally numeric(17,7) DEFAULT '0'::numeric NOT NULL,
    database_backup_retention_amount_s3 integer DEFAULT 0 NOT NULL,
    database_backup_retention_days_s3 integer DEFAULT 0 NOT NULL,
    database_backup_retention_max_storage_s3 numeric(17,7) DEFAULT '0'::numeric NOT NULL,
    timeout integer DEFAULT 3600 NOT NULL,
    disable_local_backup boolean DEFAULT false NOT NULL,
    missing_backup_notification_days integer DEFAULT 0 NOT NULL,
    last_execution_at timestamp(0) without time zone
);

CREATE SEQUENCE public.scheduled_database_backups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.scheduled_database_backups_id_seq OWNED BY public.scheduled_database_backups.id;

CREATE TABLE public.scheduled_job_deliveries (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    schedule_key character varying(255) NOT NULL,
    scheduled_for timestamp(0) with time zone NOT NULL,
    job_type character varying(255) NOT NULL,
    resource_id bigint NOT NULL,
    payload json,
    status character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    claim_token character varying(255),
    enqueued_at timestamp(0) with time zone,
    started_at timestamp(0) with time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);

CREATE SEQUENCE public.scheduled_job_deliveries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.scheduled_job_deliveries_id_seq OWNED BY public.scheduled_job_deliveries.id;

CREATE TABLE public.scheduled_job_states (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    schedule_key character varying(255) NOT NULL,
    last_scheduled_for timestamp(0) with time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);

CREATE SEQUENCE public.scheduled_job_states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.scheduled_job_states_id_seq OWNED BY public.scheduled_job_states.id;

CREATE TABLE public.scheduled_task_executions (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    status character varying(255) DEFAULT 'running'::character varying NOT NULL,
    message text,
    scheduled_task_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    finished_at timestamp(0) without time zone,
    started_at timestamp(0) without time zone,
    retry_count integer DEFAULT 0 NOT NULL,
    duration numeric(10,2),
    error_details text,
    worker_host character varying(255),
    CONSTRAINT scheduled_task_executions_status_check CHECK (((status)::text = ANY (ARRAY[('success'::character varying)::text, ('failed'::character varying)::text, ('running'::character varying)::text])))
);

CREATE SEQUENCE public.scheduled_task_executions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.scheduled_task_executions_id_seq OWNED BY public.scheduled_task_executions.id;

CREATE TABLE public.scheduled_tasks (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    name character varying(255) NOT NULL,
    command character varying(255) NOT NULL,
    frequency character varying(255) NOT NULL,
    container character varying(255),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    application_id bigint,
    service_id bigint,
    team_id bigint NOT NULL,
    timeout integer DEFAULT 300 NOT NULL
);

CREATE SEQUENCE public.scheduled_tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.scheduled_tasks_id_seq OWNED BY public.scheduled_tasks.id;

CREATE TABLE public.scheduled_volume_backup_executions (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    scheduled_volume_backup_id bigint NOT NULL,
    s3_storage_id bigint,
    status character varying(255) DEFAULT 'running'::character varying NOT NULL,
    message text,
    size bigint DEFAULT '0'::bigint NOT NULL,
    filename text,
    stop_container_ids json,
    stop_recovery_pending boolean DEFAULT false NOT NULL,
    s3_cleanup_pending boolean DEFAULT false NOT NULL,
    finished_at timestamp(0) without time zone,
    local_storage_deleted boolean DEFAULT false NOT NULL,
    s3_storage_deleted boolean DEFAULT false NOT NULL,
    s3_uploaded boolean,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    recovery_last_attempt_at timestamp(0) with time zone,
    recovery_error character varying(32),
    recovery_needs_attention boolean DEFAULT false NOT NULL,
    worker_host character varying(255),
    CONSTRAINT scheduled_volume_backup_executions_status_check CHECK (((status)::text = ANY (ARRAY[('success'::character varying)::text, ('failed'::character varying)::text, ('running'::character varying)::text])))
);

CREATE SEQUENCE public.scheduled_volume_backup_executions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.scheduled_volume_backup_executions_id_seq OWNED BY public.scheduled_volume_backup_executions.id;

CREATE TABLE public.scheduled_volume_backup_s3_storage (
    id bigint NOT NULL,
    scheduled_volume_backup_id bigint NOT NULL,
    s3_storage_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);

CREATE SEQUENCE public.scheduled_volume_backup_s3_storage_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.scheduled_volume_backup_s3_storage_id_seq OWNED BY public.scheduled_volume_backup_s3_storage.id;

CREATE TABLE public.scheduled_volume_backups (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    backupable_type character varying(255) NOT NULL,
    backupable_id bigint NOT NULL,
    team_id bigint NOT NULL,
    s3_storage_id bigint,
    frequency character varying(255) NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    save_s3 boolean DEFAULT false NOT NULL,
    disable_local_backup boolean DEFAULT false NOT NULL,
    stop_during_backup boolean DEFAULT false NOT NULL,
    retention_amount_locally integer DEFAULT 7 NOT NULL,
    retention_days_locally integer DEFAULT 0 NOT NULL,
    retention_max_storage_locally numeric(17,7) DEFAULT '0'::numeric NOT NULL,
    retention_amount_s3 integer DEFAULT 7 NOT NULL,
    retention_days_s3 integer DEFAULT 0 NOT NULL,
    retention_max_storage_s3 numeric(17,7) DEFAULT '0'::numeric NOT NULL,
    timeout integer DEFAULT 36000 NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    missing_backup_notification_days integer DEFAULT 0 NOT NULL
);

CREATE SEQUENCE public.scheduled_volume_backups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.scheduled_volume_backups_id_seq OWNED BY public.scheduled_volume_backups.id;

CREATE TABLE public.secret_manager_links (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    resourceable_type character varying(255) NOT NULL,
    resourceable_id bigint NOT NULL,
    integration_token_id bigint NOT NULL,
    settings json,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);

CREATE SEQUENCE public.secret_manager_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.secret_manager_links_id_seq OWNED BY public.secret_manager_links.id;

CREATE TABLE public.server_settings (
    id bigint NOT NULL,
    is_swarm_manager boolean DEFAULT false NOT NULL,
    is_jump_server boolean DEFAULT false NOT NULL,
    is_build_server boolean DEFAULT false NOT NULL,
    is_reachable boolean DEFAULT false NOT NULL,
    is_usable boolean DEFAULT false NOT NULL,
    server_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    wildcard_domain character varying(255),
    is_cloudflare_tunnel boolean DEFAULT false NOT NULL,
    is_logdrain_newrelic_enabled boolean DEFAULT false NOT NULL,
    logdrain_newrelic_license_key character varying(255),
    logdrain_newrelic_base_uri character varying(255),
    is_logdrain_axiom_enabled boolean DEFAULT false NOT NULL,
    logdrain_axiom_dataset_name character varying(255),
    logdrain_axiom_api_key character varying(255),
    is_swarm_worker boolean DEFAULT false NOT NULL,
    is_logdrain_custom_enabled boolean DEFAULT false NOT NULL,
    logdrain_custom_config text,
    logdrain_custom_config_parser text,
    concurrent_builds integer DEFAULT 2 NOT NULL,
    dynamic_timeout integer DEFAULT 3600 NOT NULL,
    force_disabled boolean DEFAULT false NOT NULL,
    is_metrics_enabled boolean DEFAULT false NOT NULL,
    generate_exact_labels boolean DEFAULT false NOT NULL,
    force_docker_cleanup boolean DEFAULT true NOT NULL,
    docker_cleanup_frequency character varying(255) DEFAULT '0 0 * * *'::character varying NOT NULL,
    docker_cleanup_threshold integer DEFAULT 80 NOT NULL,
    server_timezone character varying(255) DEFAULT 'UTC'::character varying NOT NULL,
    delete_unused_volumes boolean DEFAULT false NOT NULL,
    delete_unused_networks boolean DEFAULT false NOT NULL,
    is_sentinel_enabled boolean DEFAULT true NOT NULL,
    sentinel_token text,
    sentinel_metrics_refresh_rate_seconds integer DEFAULT 10 NOT NULL,
    sentinel_metrics_history_days integer DEFAULT 7 NOT NULL,
    sentinel_push_interval_seconds integer DEFAULT 60 NOT NULL,
    sentinel_custom_url character varying(255),
    server_disk_usage_notification_threshold integer DEFAULT 80 NOT NULL,
    is_sentinel_debug_enabled boolean DEFAULT false NOT NULL,
    server_disk_usage_check_frequency character varying(255) DEFAULT '0 23 * * *'::character varying NOT NULL,
    is_terminal_enabled boolean DEFAULT true NOT NULL,
    deployment_queue_limit integer DEFAULT 25 NOT NULL,
    disable_application_image_retention boolean DEFAULT false NOT NULL,
    connection_timeout integer DEFAULT 10 NOT NULL,
    docker_version character varying(255),
    docker_version_checked_at timestamp(0) without time zone,
    compose_version character varying(255),
    compose_version_checked_at timestamp(0) without time zone,
    backup_compression_cpu_percentage smallint DEFAULT '25'::smallint NOT NULL,
    is_traffic_analytics_enabled boolean DEFAULT false NOT NULL,
    geoip_maxmind_license_key text,
    traffic_topn integer DEFAULT 50 NOT NULL,
    traffic_sample_threshold integer DEFAULT 0 NOT NULL,
    traffic_retention_1h_days integer DEFAULT 30 NOT NULL,
    traffic_retention_1d_days integer DEFAULT 395 NOT NULL,
    is_geoip_enabled boolean DEFAULT true NOT NULL,
    geoip_refresh_days integer DEFAULT 30 NOT NULL,
    server_role character varying(255) DEFAULT 'both'::character varying,
    server_disk_usage_notification_interval_hours integer DEFAULT 24 NOT NULL,
    traffic_ip_mode character varying(255) DEFAULT 'full'::character varying NOT NULL,
    is_logdrain_cloudwatch_enabled boolean DEFAULT false NOT NULL,
    logdrain_cloudwatch_region character varying(255),
    logdrain_cloudwatch_group character varying(512),
    logdrain_cloudwatch_stream_prefix character varying(255),
    cloudflare_tunnel_id character varying(255),
    cloudflare_tunnel_account_id character varying(255),
    cloudflare_tunnel_integration_token_id bigint,
    traefik_certificate_resolver character varying(255) DEFAULT 'letsencrypt'::character varying,
    patch_check_frequency character varying(255),
    patch_check_result json,
    patch_check_error text,
    patch_checked_at timestamp(0) without time zone,
    is_auto_security_updates_enabled boolean DEFAULT false NOT NULL,
    auto_security_updates_time character varying(255) DEFAULT '03:00'::character varying NOT NULL,
    logdrain_axiom_domain character varying(255) DEFAULT 'us-east-1.aws.edge.axiom.co'::character varying
);

CREATE SEQUENCE public.server_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.server_settings_id_seq OWNED BY public.server_settings.id;

CREATE TABLE public.servers (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255),
    ip character varying(255) NOT NULL,
    port integer DEFAULT 22 NOT NULL,
    "user" character varying(255) DEFAULT 'root'::character varying NOT NULL,
    team_id bigint NOT NULL,
    private_key_id bigint NOT NULL,
    proxy json,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    unreachable_count integer DEFAULT 0 NOT NULL,
    high_disk_usage_notification_sent boolean DEFAULT false NOT NULL,
    log_drain_notification_sent boolean DEFAULT false NOT NULL,
    swarm_cluster integer,
    validation_logs text,
    sentinel_updated_at timestamp(0) without time zone DEFAULT '2024-11-14 12:28:18'::timestamp without time zone NOT NULL,
    deleted_at timestamp(0) without time zone,
    ip_previous character varying(255),
    hetzner_server_id bigint,
    cloud_provider_token_id bigint,
    hetzner_server_status character varying(255),
    is_validating boolean DEFAULT false NOT NULL,
    detected_traefik_version character varying(255),
    traefik_outdated_info json,
    server_metadata json,
    vultr_instance_id character varying(255),
    vultr_instance_status character varying(255),
    digitalocean_droplet_id bigint,
    digitalocean_droplet_status character varying(255),
    sentinel_waiting_since timestamp(0) without time zone,
    hostinger_virtual_machine_id bigint,
    hostinger_virtual_machine_status character varying(255),
    proxy_error_page text,
    canvas_position json
)
WITH (fillfactor='85', autovacuum_vacuum_scale_factor='0.05');

CREATE SEQUENCE public.servers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.servers_id_seq OWNED BY public.servers.id;

CREATE TABLE public.service_applications (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    human_name character varying(255),
    description text,
    fqdn text,
    ports text,
    exposes text,
    status character varying(255) DEFAULT 'exited'::character varying NOT NULL,
    service_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    exclude_from_status boolean DEFAULT false NOT NULL,
    required_fqdn boolean DEFAULT false NOT NULL,
    image character varying(255),
    is_log_drain_enabled boolean DEFAULT false NOT NULL,
    is_include_timestamps boolean DEFAULT false NOT NULL,
    deleted_at timestamp(0) without time zone,
    is_gzip_enabled boolean DEFAULT true NOT NULL,
    is_stripprefix_enabled boolean DEFAULT true NOT NULL,
    last_online_at timestamp(0) without time zone DEFAULT '2024-11-14 12:28:18'::timestamp without time zone NOT NULL,
    is_migrated boolean DEFAULT false NOT NULL,
    noindex_domains json,
    domain_dns_statuses json,
    redirect character varying(255) DEFAULT 'both'::character varying NOT NULL,
    is_force_https_enabled boolean DEFAULT true NOT NULL,
    restart_count integer DEFAULT 0 NOT NULL,
    max_restart_count integer DEFAULT 0 NOT NULL,
    restart_limit_reached boolean DEFAULT false NOT NULL,
    last_restart_at timestamp(0) without time zone,
    last_restart_type character varying(10),
    domain_port_overrides json,
    traefik_certificate_resolver character varying(255),
    is_permanent_redirect_enabled boolean DEFAULT false NOT NULL,
    CONSTRAINT service_applications_redirect_check CHECK (((redirect)::text = ANY (ARRAY[('www'::character varying)::text, ('non-www'::character varying)::text, ('both'::character varying)::text])))
)
WITH (fillfactor='85', autovacuum_vacuum_scale_factor='0.05');

CREATE SEQUENCE public.service_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.service_applications_id_seq OWNED BY public.service_applications.id;

CREATE TABLE public.service_databases (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    human_name character varying(255),
    description text,
    ports text,
    exposes text,
    status character varying(255) DEFAULT 'exited'::character varying NOT NULL,
    service_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    exclude_from_status boolean DEFAULT false NOT NULL,
    image character varying(255),
    public_port integer,
    is_public boolean DEFAULT false NOT NULL,
    is_log_drain_enabled boolean DEFAULT false NOT NULL,
    is_include_timestamps boolean DEFAULT false NOT NULL,
    deleted_at timestamp(0) without time zone,
    is_gzip_enabled boolean DEFAULT true NOT NULL,
    is_stripprefix_enabled boolean DEFAULT true NOT NULL,
    last_online_at timestamp(0) without time zone DEFAULT '2024-11-14 12:28:18'::timestamp without time zone NOT NULL,
    is_migrated boolean DEFAULT false NOT NULL,
    custom_type character varying(255),
    public_port_timeout integer DEFAULT 3600
)
WITH (fillfactor='85', autovacuum_vacuum_scale_factor='0.05');

CREATE SEQUENCE public.service_databases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.service_databases_id_seq OWNED BY public.service_databases.id;

CREATE TABLE public.services (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    environment_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    server_id bigint,
    description text,
    docker_compose_raw text NOT NULL,
    docker_compose text,
    destination_type character varying(255),
    destination_id bigint,
    deleted_at timestamp(0) without time zone,
    connect_to_docker_network boolean DEFAULT false NOT NULL,
    config_hash character varying(255),
    service_type character varying(255),
    is_container_label_escape_enabled boolean DEFAULT true NOT NULL,
    compose_parsing_version character varying(255) DEFAULT '2'::character varying NOT NULL,
    redact_all_env_values_in_logs boolean DEFAULT true NOT NULL,
    is_maintenance_enabled boolean DEFAULT false NOT NULL,
    maintenance_page text,
    include_coolify_default_variables boolean DEFAULT true NOT NULL
)
WITH (fillfactor='85');

CREATE SEQUENCE public.services_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.services_id_seq OWNED BY public.services.id;

CREATE TABLE public.sessions (
    id character varying(255) NOT NULL,
    user_id bigint,
    ip_address character varying(45),
    user_agent text,
    payload text NOT NULL,
    last_activity integer NOT NULL
);

CREATE TABLE public.shared_environment_variables (
    id bigint NOT NULL,
    key character varying(255) NOT NULL,
    value text NOT NULL,
    is_shown_once boolean DEFAULT false NOT NULL,
    type character varying(255) DEFAULT 'team'::character varying NOT NULL,
    team_id bigint NOT NULL,
    project_id bigint,
    environment_id bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    is_multiline boolean DEFAULT false NOT NULL,
    version character varying(255) DEFAULT '4.0.0-beta.239'::character varying NOT NULL,
    is_literal boolean DEFAULT false NOT NULL,
    comment character varying(256),
    server_id bigint,
    CONSTRAINT shared_environment_variables_type_check CHECK (((type)::text = ANY (ARRAY[('team'::character varying)::text, ('project'::character varying)::text, ('environment'::character varying)::text, ('server'::character varying)::text])))
);

CREATE SEQUENCE public.shared_environment_variables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.shared_environment_variables_id_seq OWNED BY public.shared_environment_variables.id;

CREATE TABLE public.slack_notification_settings (
    id bigint NOT NULL,
    team_id bigint NOT NULL,
    slack_enabled boolean DEFAULT false NOT NULL,
    slack_webhook_url text,
    deployment_success_slack_notifications boolean DEFAULT false NOT NULL,
    deployment_failure_slack_notifications boolean DEFAULT true NOT NULL,
    status_change_slack_notifications boolean DEFAULT false NOT NULL,
    backup_success_slack_notifications boolean DEFAULT false NOT NULL,
    backup_failure_slack_notifications boolean DEFAULT true NOT NULL,
    scheduled_task_success_slack_notifications boolean DEFAULT false NOT NULL,
    scheduled_task_failure_slack_notifications boolean DEFAULT true NOT NULL,
    docker_cleanup_success_slack_notifications boolean DEFAULT false NOT NULL,
    docker_cleanup_failure_slack_notifications boolean DEFAULT true NOT NULL,
    server_disk_usage_slack_notifications boolean DEFAULT true NOT NULL,
    server_reachable_slack_notifications boolean DEFAULT false NOT NULL,
    server_unreachable_slack_notifications boolean DEFAULT true NOT NULL,
    server_patch_slack_notifications boolean DEFAULT true NOT NULL,
    traefik_outdated_slack_notifications boolean DEFAULT true NOT NULL,
    restart_limit_reached_slack_notifications boolean DEFAULT true NOT NULL,
    failure_count integer DEFAULT 0 NOT NULL
);

CREATE SEQUENCE public.slack_notification_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.slack_notification_settings_id_seq OWNED BY public.slack_notification_settings.id;

CREATE TABLE public.ssl_certificates (
    id bigint NOT NULL,
    ssl_certificate text NOT NULL,
    ssl_private_key text NOT NULL,
    configuration_dir text,
    mount_path text,
    resource_type character varying(255),
    resource_id bigint,
    server_id bigint NOT NULL,
    common_name text NOT NULL,
    subject_alternative_names json,
    valid_until timestamp(0) without time zone NOT NULL,
    is_ca_certificate boolean DEFAULT false NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);

CREATE SEQUENCE public.ssl_certificates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.ssl_certificates_id_seq OWNED BY public.ssl_certificates.id;

CREATE TABLE public.standalone_clickhouses (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255),
    clickhouse_admin_user character varying(255) DEFAULT 'default'::character varying NOT NULL,
    clickhouse_admin_password text NOT NULL,
    is_log_drain_enabled boolean DEFAULT false NOT NULL,
    is_include_timestamps boolean DEFAULT false NOT NULL,
    deleted_at timestamp(0) without time zone,
    status character varying(255) DEFAULT 'exited'::character varying NOT NULL,
    image character varying(255) DEFAULT 'clickhouse/clickhouse-server:25.11'::character varying NOT NULL,
    is_public boolean DEFAULT false NOT NULL,
    public_port integer,
    ports_mappings text,
    limits_memory character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_memory_swap character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_memory_swappiness integer DEFAULT 60 NOT NULL,
    limits_memory_reservation character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_cpus character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_cpuset character varying(255),
    limits_cpu_shares integer DEFAULT 1024 NOT NULL,
    started_at timestamp(0) without time zone,
    destination_type character varying(255) NOT NULL,
    destination_id bigint NOT NULL,
    environment_id bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    config_hash character varying(255),
    custom_docker_run_options text,
    last_online_at timestamp(0) without time zone DEFAULT '2024-11-14 12:28:18'::timestamp without time zone NOT NULL,
    clickhouse_db character varying(255) DEFAULT 'default'::character varying NOT NULL,
    restart_count integer DEFAULT 0 NOT NULL,
    last_restart_at timestamp(0) without time zone,
    last_restart_type character varying(10),
    public_port_timeout integer DEFAULT 3600,
    health_check_enabled boolean DEFAULT true NOT NULL,
    health_check_interval integer DEFAULT 15 NOT NULL,
    health_check_timeout integer DEFAULT 5 NOT NULL,
    health_check_retries integer DEFAULT 5 NOT NULL,
    health_check_start_period integer DEFAULT 5 NOT NULL,
    redact_all_env_values_in_logs boolean DEFAULT true NOT NULL,
    include_coolify_default_variables boolean DEFAULT true NOT NULL
)
WITH (fillfactor='85');

CREATE SEQUENCE public.standalone_clickhouses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.standalone_clickhouses_id_seq OWNED BY public.standalone_clickhouses.id;

CREATE TABLE public.standalone_dockers (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    uuid character varying(255) NOT NULL,
    network character varying(255) NOT NULL,
    server_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);

CREATE SEQUENCE public.standalone_dockers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.standalone_dockers_id_seq OWNED BY public.standalone_dockers.id;

CREATE TABLE public.standalone_dragonflies (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255),
    dragonfly_password text NOT NULL,
    is_log_drain_enabled boolean DEFAULT false NOT NULL,
    is_include_timestamps boolean DEFAULT false NOT NULL,
    deleted_at timestamp(0) without time zone,
    status character varying(255) DEFAULT 'exited'::character varying NOT NULL,
    image character varying(255) DEFAULT 'docker.dragonflydb.io/dragonflydb/dragonfly'::character varying NOT NULL,
    is_public boolean DEFAULT false NOT NULL,
    public_port integer,
    ports_mappings text,
    limits_memory character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_memory_swap character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_memory_swappiness integer DEFAULT 60 NOT NULL,
    limits_memory_reservation character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_cpus character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_cpuset character varying(255),
    limits_cpu_shares integer DEFAULT 1024 NOT NULL,
    started_at timestamp(0) without time zone,
    destination_type character varying(255) NOT NULL,
    destination_id bigint NOT NULL,
    environment_id bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    config_hash character varying(255),
    custom_docker_run_options text,
    last_online_at timestamp(0) without time zone DEFAULT '2024-11-14 12:28:18'::timestamp without time zone NOT NULL,
    enable_ssl boolean DEFAULT false NOT NULL,
    restart_count integer DEFAULT 0 NOT NULL,
    last_restart_at timestamp(0) without time zone,
    last_restart_type character varying(10),
    public_port_timeout integer DEFAULT 3600,
    health_check_enabled boolean DEFAULT true NOT NULL,
    health_check_interval integer DEFAULT 15 NOT NULL,
    health_check_timeout integer DEFAULT 5 NOT NULL,
    health_check_retries integer DEFAULT 5 NOT NULL,
    health_check_start_period integer DEFAULT 5 NOT NULL,
    legacy_password_quoting boolean DEFAULT false NOT NULL,
    redact_all_env_values_in_logs boolean DEFAULT true NOT NULL,
    include_coolify_default_variables boolean DEFAULT true NOT NULL
)
WITH (fillfactor='85');

CREATE SEQUENCE public.standalone_dragonflies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.standalone_dragonflies_id_seq OWNED BY public.standalone_dragonflies.id;

CREATE TABLE public.standalone_keydbs (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255),
    keydb_password text NOT NULL,
    keydb_conf text,
    is_log_drain_enabled boolean DEFAULT false NOT NULL,
    is_include_timestamps boolean DEFAULT false NOT NULL,
    deleted_at timestamp(0) without time zone,
    status character varying(255) DEFAULT 'exited'::character varying NOT NULL,
    image character varying(255) DEFAULT 'eqalpha/keydb:latest'::character varying NOT NULL,
    is_public boolean DEFAULT false NOT NULL,
    public_port integer,
    ports_mappings text,
    limits_memory character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_memory_swap character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_memory_swappiness integer DEFAULT 60 NOT NULL,
    limits_memory_reservation character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_cpus character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_cpuset character varying(255),
    limits_cpu_shares integer DEFAULT 1024 NOT NULL,
    started_at timestamp(0) without time zone,
    destination_type character varying(255) NOT NULL,
    destination_id bigint NOT NULL,
    environment_id bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    config_hash character varying(255),
    custom_docker_run_options text,
    last_online_at timestamp(0) without time zone DEFAULT '2024-11-14 12:28:18'::timestamp without time zone NOT NULL,
    enable_ssl boolean DEFAULT false NOT NULL,
    restart_count integer DEFAULT 0 NOT NULL,
    last_restart_at timestamp(0) without time zone,
    last_restart_type character varying(10),
    public_port_timeout integer DEFAULT 3600,
    health_check_enabled boolean DEFAULT true NOT NULL,
    health_check_interval integer DEFAULT 15 NOT NULL,
    health_check_timeout integer DEFAULT 5 NOT NULL,
    health_check_retries integer DEFAULT 5 NOT NULL,
    health_check_start_period integer DEFAULT 5 NOT NULL,
    legacy_password_quoting boolean DEFAULT false NOT NULL,
    redact_all_env_values_in_logs boolean DEFAULT true NOT NULL,
    include_coolify_default_variables boolean DEFAULT true NOT NULL
)
WITH (fillfactor='85');

CREATE SEQUENCE public.standalone_keydbs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.standalone_keydbs_id_seq OWNED BY public.standalone_keydbs.id;

CREATE TABLE public.standalone_mariadbs (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255),
    mariadb_root_password text NOT NULL,
    mariadb_user character varying(255) DEFAULT 'mariadb'::character varying NOT NULL,
    mariadb_password text NOT NULL,
    mariadb_database character varying(255) DEFAULT 'default'::character varying NOT NULL,
    mariadb_conf text,
    status character varying(255) DEFAULT 'exited'::character varying NOT NULL,
    image character varying(255) DEFAULT 'mariadb:11'::character varying NOT NULL,
    is_public boolean DEFAULT false NOT NULL,
    public_port integer,
    ports_mappings text,
    limits_memory character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_memory_swap character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_memory_swappiness integer DEFAULT 60 NOT NULL,
    limits_memory_reservation character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_cpus character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_cpuset character varying(255),
    limits_cpu_shares integer DEFAULT 1024 NOT NULL,
    started_at timestamp(0) without time zone,
    destination_type character varying(255) NOT NULL,
    destination_id bigint NOT NULL,
    environment_id bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    is_log_drain_enabled boolean DEFAULT false NOT NULL,
    deleted_at timestamp(0) without time zone,
    config_hash character varying(255),
    custom_docker_run_options text,
    last_online_at timestamp(0) without time zone DEFAULT '2024-11-14 12:28:18'::timestamp without time zone NOT NULL,
    enable_ssl boolean DEFAULT false NOT NULL,
    restart_count integer DEFAULT 0 NOT NULL,
    last_restart_at timestamp(0) without time zone,
    last_restart_type character varying(10),
    public_port_timeout integer DEFAULT 3600,
    health_check_enabled boolean DEFAULT true NOT NULL,
    health_check_interval integer DEFAULT 15 NOT NULL,
    health_check_timeout integer DEFAULT 5 NOT NULL,
    health_check_retries integer DEFAULT 5 NOT NULL,
    health_check_start_period integer DEFAULT 5 NOT NULL,
    redact_all_env_values_in_logs boolean DEFAULT true NOT NULL,
    include_coolify_default_variables boolean DEFAULT true NOT NULL
)
WITH (fillfactor='85');

CREATE SEQUENCE public.standalone_mariadbs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.standalone_mariadbs_id_seq OWNED BY public.standalone_mariadbs.id;

CREATE TABLE public.standalone_mongodbs (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255),
    mongo_conf text,
    mongo_initdb_root_username text DEFAULT 'root'::text NOT NULL,
    mongo_initdb_root_password text NOT NULL,
    mongo_initdb_database text DEFAULT 'default'::text NOT NULL,
    status character varying(255) DEFAULT 'exited'::character varying NOT NULL,
    image character varying(255) DEFAULT 'mongo:7'::character varying NOT NULL,
    is_public boolean DEFAULT false NOT NULL,
    public_port integer,
    ports_mappings text,
    limits_memory character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_memory_swap character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_memory_swappiness integer DEFAULT 60 NOT NULL,
    limits_memory_reservation character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_cpus character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_cpuset character varying(255),
    limits_cpu_shares integer DEFAULT 1024 NOT NULL,
    started_at timestamp(0) without time zone,
    destination_type character varying(255) NOT NULL,
    destination_id bigint NOT NULL,
    environment_id bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    is_log_drain_enabled boolean DEFAULT false NOT NULL,
    is_include_timestamps boolean DEFAULT false NOT NULL,
    deleted_at timestamp(0) without time zone,
    config_hash character varying(255),
    custom_docker_run_options text,
    last_online_at timestamp(0) without time zone DEFAULT '2024-11-14 12:28:18'::timestamp without time zone NOT NULL,
    enable_ssl boolean DEFAULT false NOT NULL,
    ssl_mode character varying(255) DEFAULT 'require'::character varying NOT NULL,
    restart_count integer DEFAULT 0 NOT NULL,
    last_restart_at timestamp(0) without time zone,
    last_restart_type character varying(10),
    public_port_timeout integer DEFAULT 3600,
    health_check_enabled boolean DEFAULT true NOT NULL,
    health_check_interval integer DEFAULT 15 NOT NULL,
    health_check_timeout integer DEFAULT 5 NOT NULL,
    health_check_retries integer DEFAULT 5 NOT NULL,
    health_check_start_period integer DEFAULT 5 NOT NULL,
    redact_all_env_values_in_logs boolean DEFAULT true NOT NULL,
    include_coolify_default_variables boolean DEFAULT true NOT NULL,
    CONSTRAINT standalone_mongodbs_ssl_mode_check CHECK (((ssl_mode)::text = ANY (ARRAY[('allow'::character varying)::text, ('prefer'::character varying)::text, ('require'::character varying)::text, ('verify-full'::character varying)::text])))
)
WITH (fillfactor='85');

CREATE SEQUENCE public.standalone_mongodbs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.standalone_mongodbs_id_seq OWNED BY public.standalone_mongodbs.id;

CREATE TABLE public.standalone_mysqls (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255),
    mysql_root_password text NOT NULL,
    mysql_user character varying(255) DEFAULT 'mysql'::character varying NOT NULL,
    mysql_password text NOT NULL,
    mysql_database character varying(255) DEFAULT 'default'::character varying NOT NULL,
    mysql_conf text,
    status character varying(255) DEFAULT 'exited'::character varying NOT NULL,
    image character varying(255) DEFAULT 'mysql:8'::character varying NOT NULL,
    is_public boolean DEFAULT false NOT NULL,
    public_port integer,
    ports_mappings text,
    limits_memory character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_memory_swap character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_memory_swappiness integer DEFAULT 60 NOT NULL,
    limits_memory_reservation character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_cpus character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_cpuset character varying(255),
    limits_cpu_shares integer DEFAULT 1024 NOT NULL,
    started_at timestamp(0) without time zone,
    destination_type character varying(255) NOT NULL,
    destination_id bigint NOT NULL,
    environment_id bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    is_log_drain_enabled boolean DEFAULT false NOT NULL,
    is_include_timestamps boolean DEFAULT false NOT NULL,
    deleted_at timestamp(0) without time zone,
    config_hash character varying(255),
    custom_docker_run_options text,
    last_online_at timestamp(0) without time zone DEFAULT '2024-11-14 12:28:18'::timestamp without time zone NOT NULL,
    enable_ssl boolean DEFAULT false NOT NULL,
    ssl_mode character varying(255) DEFAULT 'REQUIRED'::character varying NOT NULL,
    restart_count integer DEFAULT 0 NOT NULL,
    last_restart_at timestamp(0) without time zone,
    last_restart_type character varying(10),
    public_port_timeout integer DEFAULT 3600,
    health_check_enabled boolean DEFAULT true NOT NULL,
    health_check_interval integer DEFAULT 15 NOT NULL,
    health_check_timeout integer DEFAULT 5 NOT NULL,
    health_check_retries integer DEFAULT 5 NOT NULL,
    health_check_start_period integer DEFAULT 5 NOT NULL,
    redact_all_env_values_in_logs boolean DEFAULT true NOT NULL,
    include_coolify_default_variables boolean DEFAULT true NOT NULL,
    CONSTRAINT standalone_mysqls_ssl_mode_check CHECK (((ssl_mode)::text = ANY (ARRAY[('PREFERRED'::character varying)::text, ('REQUIRED'::character varying)::text, ('VERIFY_CA'::character varying)::text, ('VERIFY_IDENTITY'::character varying)::text])))
)
WITH (fillfactor='85');

CREATE SEQUENCE public.standalone_mysqls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.standalone_mysqls_id_seq OWNED BY public.standalone_mysqls.id;

CREATE TABLE public.standalone_postgresqls (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255),
    postgres_user character varying(255) DEFAULT 'postgres'::character varying NOT NULL,
    postgres_password text NOT NULL,
    postgres_db character varying(255) DEFAULT 'postgres'::character varying NOT NULL,
    postgres_initdb_args character varying(255),
    postgres_host_auth_method character varying(255),
    init_scripts json,
    status character varying(255) DEFAULT 'exited'::character varying NOT NULL,
    image character varying(255) DEFAULT 'postgres:16-alpine'::character varying NOT NULL,
    is_public boolean DEFAULT false NOT NULL,
    public_port integer,
    ports_mappings text,
    limits_memory character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_memory_swap character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_memory_swappiness integer DEFAULT 60 NOT NULL,
    limits_memory_reservation character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_cpus character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_cpuset character varying(255),
    limits_cpu_shares integer DEFAULT 1024 NOT NULL,
    started_at timestamp(0) without time zone,
    destination_type character varying(255) NOT NULL,
    destination_id bigint NOT NULL,
    environment_id bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    postgres_conf text,
    is_log_drain_enabled boolean DEFAULT false NOT NULL,
    is_include_timestamps boolean DEFAULT false NOT NULL,
    deleted_at timestamp(0) without time zone,
    config_hash character varying(255),
    custom_docker_run_options text,
    last_online_at timestamp(0) without time zone DEFAULT '2024-11-14 12:28:18'::timestamp without time zone NOT NULL,
    enable_ssl boolean DEFAULT false NOT NULL,
    ssl_mode character varying(255) DEFAULT 'require'::character varying NOT NULL,
    restart_count integer DEFAULT 0 NOT NULL,
    last_restart_at timestamp(0) without time zone,
    last_restart_type character varying(10),
    public_port_timeout integer DEFAULT 3600,
    health_check_enabled boolean DEFAULT true NOT NULL,
    health_check_interval integer DEFAULT 15 NOT NULL,
    health_check_timeout integer DEFAULT 5 NOT NULL,
    health_check_retries integer DEFAULT 5 NOT NULL,
    health_check_start_period integer DEFAULT 5 NOT NULL,
    redact_all_env_values_in_logs boolean DEFAULT true NOT NULL,
    include_coolify_default_variables boolean DEFAULT true NOT NULL,
    CONSTRAINT standalone_postgresqls_ssl_mode_check CHECK (((ssl_mode)::text = ANY (ARRAY[('allow'::character varying)::text, ('prefer'::character varying)::text, ('require'::character varying)::text, ('verify-ca'::character varying)::text, ('verify-full'::character varying)::text])))
)
WITH (fillfactor='85', autovacuum_vacuum_scale_factor='0.05');

CREATE SEQUENCE public.standalone_postgresqls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.standalone_postgresqls_id_seq OWNED BY public.standalone_postgresqls.id;

CREATE TABLE public.standalone_redis (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255),
    redis_conf text,
    status character varying(255) DEFAULT 'exited'::character varying NOT NULL,
    image character varying(255) DEFAULT 'redis:7.2'::character varying NOT NULL,
    is_public boolean DEFAULT false NOT NULL,
    public_port integer,
    ports_mappings text,
    limits_memory character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_memory_swap character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_memory_swappiness integer DEFAULT 60 NOT NULL,
    limits_memory_reservation character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_cpus character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_cpuset character varying(255),
    limits_cpu_shares integer DEFAULT 1024 NOT NULL,
    started_at timestamp(0) without time zone,
    destination_type character varying(255) NOT NULL,
    destination_id bigint NOT NULL,
    environment_id bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    is_log_drain_enabled boolean DEFAULT false NOT NULL,
    is_include_timestamps boolean DEFAULT false NOT NULL,
    deleted_at timestamp(0) without time zone,
    config_hash character varying(255),
    custom_docker_run_options text,
    last_online_at timestamp(0) without time zone DEFAULT '2024-11-14 12:28:18'::timestamp without time zone NOT NULL,
    enable_ssl boolean DEFAULT false NOT NULL,
    restart_count integer DEFAULT 0 NOT NULL,
    last_restart_at timestamp(0) without time zone,
    last_restart_type character varying(10),
    public_port_timeout integer DEFAULT 3600,
    health_check_enabled boolean DEFAULT true NOT NULL,
    health_check_interval integer DEFAULT 15 NOT NULL,
    health_check_timeout integer DEFAULT 5 NOT NULL,
    health_check_retries integer DEFAULT 5 NOT NULL,
    health_check_start_period integer DEFAULT 5 NOT NULL,
    legacy_password_quoting boolean DEFAULT false NOT NULL,
    redact_all_env_values_in_logs boolean DEFAULT true NOT NULL,
    include_coolify_default_variables boolean DEFAULT true NOT NULL
)
WITH (fillfactor='85');

CREATE SEQUENCE public.standalone_redis_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.standalone_redis_id_seq OWNED BY public.standalone_redis.id;

CREATE TABLE public.standalone_sqlites (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255),
    sqlite_databases character varying(255) DEFAULT 'database.sqlite'::character varying NOT NULL,
    is_log_drain_enabled boolean DEFAULT false NOT NULL,
    is_include_timestamps boolean DEFAULT false NOT NULL,
    deleted_at timestamp(0) without time zone,
    status character varying(255) DEFAULT 'exited'::character varying NOT NULL,
    restart_count integer DEFAULT 0 NOT NULL,
    last_restart_at timestamp(0) without time zone,
    last_restart_type character varying(10),
    image character varying(255) NOT NULL,
    is_public boolean DEFAULT false NOT NULL,
    limits_memory character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_memory_swap character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_memory_swappiness integer DEFAULT 60 NOT NULL,
    limits_memory_reservation character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_cpus character varying(255) DEFAULT '0'::character varying NOT NULL,
    limits_cpuset character varying(255),
    limits_cpu_shares integer DEFAULT 1024 NOT NULL,
    started_at timestamp(0) without time zone,
    destination_type character varying(255) NOT NULL,
    destination_id bigint NOT NULL,
    environment_id bigint,
    config_hash character varying(255),
    custom_docker_run_options text,
    health_check_enabled boolean DEFAULT true NOT NULL,
    health_check_interval integer DEFAULT 15 NOT NULL,
    health_check_timeout integer DEFAULT 5 NOT NULL,
    health_check_retries integer DEFAULT 5 NOT NULL,
    health_check_start_period integer DEFAULT 5 NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    last_online_at timestamp(0) without time zone DEFAULT '2026-10-08 00:01:41'::timestamp without time zone NOT NULL,
    redact_all_env_values_in_logs boolean DEFAULT true NOT NULL,
    include_coolify_default_variables boolean DEFAULT true NOT NULL
);

CREATE SEQUENCE public.standalone_sqlites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.standalone_sqlites_id_seq OWNED BY public.standalone_sqlites.id;

CREATE TABLE public.subscriptions (
    id bigint NOT NULL,
    team_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    stripe_invoice_paid boolean DEFAULT false NOT NULL,
    stripe_subscription_id character varying(255),
    stripe_customer_id character varying(255),
    stripe_cancel_at_period_end boolean DEFAULT false NOT NULL,
    stripe_plan_id character varying(255),
    stripe_feedback character varying(255),
    stripe_comment text,
    stripe_trial_already_ended boolean DEFAULT false NOT NULL,
    stripe_past_due boolean DEFAULT false NOT NULL,
    stripe_refunded_at timestamp(0) without time zone,
    ended_at timestamp(0) without time zone,
    stripe_checkout_reminder_sent_at timestamp(0) without time zone
);

CREATE SEQUENCE public.subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.subscriptions_id_seq OWNED BY public.subscriptions.id;

CREATE TABLE public.swarm_dockers (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    uuid character varying(255) NOT NULL,
    server_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    network character varying(255) NOT NULL
);

CREATE SEQUENCE public.swarm_dockers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.swarm_dockers_id_seq OWNED BY public.swarm_dockers.id;

CREATE TABLE public.taggables (
    tag_id bigint NOT NULL,
    taggable_id bigint NOT NULL,
    taggable_type character varying(255) NOT NULL
);

CREATE TABLE public.tags (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    team_id bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);

CREATE SEQUENCE public.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;

CREATE TABLE public.team_invitations (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    team_id bigint NOT NULL,
    email character varying(255) NOT NULL,
    role character varying(255) DEFAULT 'member'::character varying NOT NULL,
    link text NOT NULL,
    via character varying(255) DEFAULT 'link'::character varying NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    access json
);

CREATE SEQUENCE public.team_invitations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.team_invitations_id_seq OWNED BY public.team_invitations.id;

CREATE TABLE public.team_user (
    id bigint NOT NULL,
    team_id bigint NOT NULL,
    user_id bigint NOT NULL,
    role character varying(255) DEFAULT 'member'::character varying NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    access json
);

CREATE SEQUENCE public.team_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.team_user_id_seq OWNED BY public.team_user.id;

CREATE TABLE public.teams (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255),
    personal_team boolean DEFAULT false NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    show_boarding boolean DEFAULT false NOT NULL,
    custom_server_limit integer,
    is_mcp_server_enabled boolean DEFAULT true NOT NULL,
    is_build_server_fallback_enabled boolean DEFAULT true NOT NULL,
    avatar_path character varying(255),
    avatar_storage_type character varying(255),
    avatar_s3_storage_id bigint,
    is_two_factor_required boolean DEFAULT false NOT NULL
);

CREATE SEQUENCE public.teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.teams_id_seq OWNED BY public.teams.id;

CREATE TABLE public.telegram_notification_settings (
    id bigint NOT NULL,
    team_id bigint NOT NULL,
    telegram_enabled boolean DEFAULT false NOT NULL,
    telegram_token text,
    telegram_chat_id text,
    deployment_success_telegram_notifications boolean DEFAULT false NOT NULL,
    deployment_failure_telegram_notifications boolean DEFAULT true NOT NULL,
    status_change_telegram_notifications boolean DEFAULT false NOT NULL,
    backup_success_telegram_notifications boolean DEFAULT false NOT NULL,
    backup_failure_telegram_notifications boolean DEFAULT true NOT NULL,
    scheduled_task_success_telegram_notifications boolean DEFAULT false NOT NULL,
    scheduled_task_failure_telegram_notifications boolean DEFAULT true NOT NULL,
    docker_cleanup_success_telegram_notifications boolean DEFAULT false NOT NULL,
    docker_cleanup_failure_telegram_notifications boolean DEFAULT true NOT NULL,
    server_disk_usage_telegram_notifications boolean DEFAULT true NOT NULL,
    server_reachable_telegram_notifications boolean DEFAULT false NOT NULL,
    server_unreachable_telegram_notifications boolean DEFAULT true NOT NULL,
    telegram_notifications_deployment_success_thread_id text,
    telegram_notifications_deployment_failure_thread_id text,
    telegram_notifications_status_change_thread_id text,
    telegram_notifications_backup_success_thread_id text,
    telegram_notifications_backup_failure_thread_id text,
    telegram_notifications_scheduled_task_success_thread_id text,
    telegram_notifications_scheduled_task_failure_thread_id text,
    telegram_notifications_docker_cleanup_success_thread_id text,
    telegram_notifications_docker_cleanup_failure_thread_id text,
    telegram_notifications_server_disk_usage_thread_id text,
    telegram_notifications_server_reachable_thread_id text,
    telegram_notifications_server_unreachable_thread_id text,
    server_patch_telegram_notifications boolean DEFAULT true NOT NULL,
    telegram_notifications_server_patch_thread_id character varying(255),
    telegram_notifications_traefik_outdated_thread_id text,
    traefik_outdated_telegram_notifications boolean DEFAULT true NOT NULL,
    restart_limit_reached_telegram_notifications boolean DEFAULT true NOT NULL,
    telegram_notifications_restart_limit_reached_thread_id text,
    failure_count integer DEFAULT 0 NOT NULL
);

CREATE SEQUENCE public.telegram_notification_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.telegram_notification_settings_id_seq OWNED BY public.telegram_notification_settings.id;

CREATE TABLE public.telescope_entries (
    sequence bigint NOT NULL,
    uuid uuid NOT NULL,
    batch_id uuid NOT NULL,
    family_hash character varying(255),
    should_display_on_index boolean DEFAULT true NOT NULL,
    type character varying(20) NOT NULL,
    content text NOT NULL,
    created_at timestamp(0) without time zone
);

CREATE SEQUENCE public.telescope_entries_sequence_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.telescope_entries_sequence_seq OWNED BY public.telescope_entries.sequence;

CREATE TABLE public.telescope_entries_tags (
    entry_uuid uuid NOT NULL,
    tag character varying(255) NOT NULL
);

CREATE TABLE public.telescope_monitoring (
    tag character varying(255) NOT NULL
);

CREATE TABLE public.user_changelog_reads (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    release_tag character varying(255) NOT NULL,
    read_at timestamp(0) without time zone NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);

CREATE SEQUENCE public.user_changelog_reads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.user_changelog_reads_id_seq OWNED BY public.user_changelog_reads.id;

CREATE TABLE public.users (
    id bigint NOT NULL,
    name character varying(255) DEFAULT 'Anonymous'::character varying NOT NULL,
    email character varying(255) NOT NULL,
    email_verified_at timestamp(0) without time zone,
    password character varying(255),
    remember_token character varying(100),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    two_factor_secret text,
    two_factor_recovery_codes text,
    two_factor_confirmed_at timestamp(0) without time zone,
    force_password_reset boolean DEFAULT false NOT NULL,
    marketing_emails boolean DEFAULT true NOT NULL,
    pending_email character varying(255),
    email_change_code character varying(6),
    email_change_code_expires_at timestamp(0) without time zone,
    avatar_path character varying(255),
    avatar_storage_type character varying(255),
    avatar_s3_storage_id bigint,
    current_team_id bigint,
    created_before_oauth_identities boolean DEFAULT false NOT NULL
);

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;

CREATE TABLE public.volume_backup_s3_replicas (
    id bigint NOT NULL,
    execution_id bigint NOT NULL,
    s3_storage_id bigint,
    s3_uploaded boolean,
    s3_storage_deleted boolean DEFAULT false NOT NULL,
    message text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);

CREATE SEQUENCE public.volume_backup_s3_replicas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.volume_backup_s3_replicas_id_seq OWNED BY public.volume_backup_s3_replicas.id;

CREATE TABLE public.webhook_notification_settings (
    id bigint NOT NULL,
    team_id bigint NOT NULL,
    webhook_enabled boolean DEFAULT false NOT NULL,
    webhook_url text,
    deployment_success_webhook_notifications boolean DEFAULT false NOT NULL,
    deployment_failure_webhook_notifications boolean DEFAULT true NOT NULL,
    status_change_webhook_notifications boolean DEFAULT false NOT NULL,
    backup_success_webhook_notifications boolean DEFAULT false NOT NULL,
    backup_failure_webhook_notifications boolean DEFAULT true NOT NULL,
    scheduled_task_success_webhook_notifications boolean DEFAULT false NOT NULL,
    scheduled_task_failure_webhook_notifications boolean DEFAULT true NOT NULL,
    docker_cleanup_success_webhook_notifications boolean DEFAULT false NOT NULL,
    docker_cleanup_failure_webhook_notifications boolean DEFAULT true NOT NULL,
    server_disk_usage_webhook_notifications boolean DEFAULT true NOT NULL,
    server_reachable_webhook_notifications boolean DEFAULT false NOT NULL,
    server_unreachable_webhook_notifications boolean DEFAULT true NOT NULL,
    server_patch_webhook_notifications boolean DEFAULT false NOT NULL,
    traefik_outdated_webhook_notifications boolean DEFAULT true NOT NULL,
    restart_limit_reached_webhook_notifications boolean DEFAULT true NOT NULL,
    failure_count integer DEFAULT 0 NOT NULL
);

CREATE SEQUENCE public.webhook_notification_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.webhook_notification_settings_id_seq OWNED BY public.webhook_notification_settings.id;

ALTER TABLE ONLY public.activity_log ALTER COLUMN id SET DEFAULT nextval('public.activity_log_id_seq'::regclass);

ALTER TABLE ONLY public.additional_destinations ALTER COLUMN id SET DEFAULT nextval('public.additional_destinations_id_seq'::regclass);

ALTER TABLE ONLY public.application_deployment_queues ALTER COLUMN id SET DEFAULT nextval('public.application_deployment_queues_id_seq'::regclass);

ALTER TABLE ONLY public.application_previews ALTER COLUMN id SET DEFAULT nextval('public.application_previews_id_seq'::regclass);

ALTER TABLE ONLY public.application_settings ALTER COLUMN id SET DEFAULT nextval('public.application_settings_id_seq'::regclass);

ALTER TABLE ONLY public.applications ALTER COLUMN id SET DEFAULT nextval('public.applications_id_seq'::regclass);

ALTER TABLE ONLY public.audit_events ALTER COLUMN id SET DEFAULT nextval('public.audit_events_id_seq'::regclass);

ALTER TABLE ONLY public.cloud_init_scripts ALTER COLUMN id SET DEFAULT nextval('public.cloud_init_scripts_id_seq'::regclass);

ALTER TABLE ONLY public.cloud_provider_tokens ALTER COLUMN id SET DEFAULT nextval('public.cloud_provider_tokens_id_seq'::regclass);

ALTER TABLE ONLY public.database_backup_s3_replicas ALTER COLUMN id SET DEFAULT nextval('public.database_backup_s3_replicas_id_seq'::regclass);

ALTER TABLE ONLY public.discord_notification_settings ALTER COLUMN id SET DEFAULT nextval('public.discord_notification_settings_id_seq'::regclass);

ALTER TABLE ONLY public.dns_provider_zones ALTER COLUMN id SET DEFAULT nextval('public.dns_provider_zones_id_seq'::regclass);

ALTER TABLE ONLY public.docker_cleanup_executions ALTER COLUMN id SET DEFAULT nextval('public.docker_cleanup_executions_id_seq'::regclass);

ALTER TABLE ONLY public.email_notification_settings ALTER COLUMN id SET DEFAULT nextval('public.email_notification_settings_id_seq'::regclass);

ALTER TABLE ONLY public.environment_variables ALTER COLUMN id SET DEFAULT nextval('public.environment_variables_id_seq'::regclass);

ALTER TABLE ONLY public.environments ALTER COLUMN id SET DEFAULT nextval('public.environments_id_seq'::regclass);

ALTER TABLE ONLY public.failed_jobs ALTER COLUMN id SET DEFAULT nextval('public.failed_jobs_id_seq'::regclass);

ALTER TABLE ONLY public.gitea_apps ALTER COLUMN id SET DEFAULT nextval('public.gitea_apps_id_seq'::regclass);

ALTER TABLE ONLY public.github_apps ALTER COLUMN id SET DEFAULT nextval('public.github_apps_id_seq'::regclass);

ALTER TABLE ONLY public.github_runner_configs ALTER COLUMN id SET DEFAULT nextval('public.github_runner_configs_id_seq'::regclass);

ALTER TABLE ONLY public.github_runner_executions ALTER COLUMN id SET DEFAULT nextval('public.github_runner_executions_id_seq'::regclass);

ALTER TABLE ONLY public.gitlab_apps ALTER COLUMN id SET DEFAULT nextval('public.gitlab_apps_id_seq'::regclass);

ALTER TABLE ONLY public.instance_settings ALTER COLUMN id SET DEFAULT nextval('public.instance_settings_id_seq'::regclass);

ALTER TABLE ONLY public.integration_tokens ALTER COLUMN id SET DEFAULT nextval('public.integration_tokens_id_seq'::regclass);

ALTER TABLE ONLY public.local_file_volumes ALTER COLUMN id SET DEFAULT nextval('public.local_file_volumes_id_seq'::regclass);

ALTER TABLE ONLY public.local_persistent_volumes ALTER COLUMN id SET DEFAULT nextval('public.local_persistent_volumes_id_seq'::regclass);

ALTER TABLE ONLY public.managed_dns_record_references ALTER COLUMN id SET DEFAULT nextval('public.managed_dns_record_references_id_seq'::regclass);

ALTER TABLE ONLY public.managed_dns_records ALTER COLUMN id SET DEFAULT nextval('public.managed_dns_records_id_seq'::regclass);

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);

ALTER TABLE ONLY public.notification_throttles ALTER COLUMN id SET DEFAULT nextval('public.notification_throttles_id_seq'::regclass);

ALTER TABLE ONLY public.oauth_identities ALTER COLUMN id SET DEFAULT nextval('public.oauth_identities_id_seq'::regclass);

ALTER TABLE ONLY public.oauth_settings ALTER COLUMN id SET DEFAULT nextval('public.oauth_settings_id_seq'::regclass);

ALTER TABLE ONLY public.passkeys ALTER COLUMN id SET DEFAULT nextval('public.passkeys_id_seq'::regclass);

ALTER TABLE ONLY public.personal_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.personal_access_tokens_id_seq'::regclass);

ALTER TABLE ONLY public.private_keys ALTER COLUMN id SET DEFAULT nextval('public.private_keys_id_seq'::regclass);

ALTER TABLE ONLY public.project_settings ALTER COLUMN id SET DEFAULT nextval('public.project_settings_id_seq'::regclass);

ALTER TABLE ONLY public.projects ALTER COLUMN id SET DEFAULT nextval('public.projects_id_seq'::regclass);

ALTER TABLE ONLY public.pushover_notification_settings ALTER COLUMN id SET DEFAULT nextval('public.pushover_notification_settings_id_seq'::regclass);

ALTER TABLE ONLY public.resource_links ALTER COLUMN id SET DEFAULT nextval('public.resource_links_id_seq'::regclass);

ALTER TABLE ONLY public.s3_storages ALTER COLUMN id SET DEFAULT nextval('public.s3_storages_id_seq'::regclass);

ALTER TABLE ONLY public.scheduled_database_backup_executions ALTER COLUMN id SET DEFAULT nextval('public.scheduled_database_backup_executions_id_seq'::regclass);

ALTER TABLE ONLY public.scheduled_database_backup_s3_storage ALTER COLUMN id SET DEFAULT nextval('public.scheduled_database_backup_s3_storage_id_seq'::regclass);

ALTER TABLE ONLY public.scheduled_database_backups ALTER COLUMN id SET DEFAULT nextval('public.scheduled_database_backups_id_seq'::regclass);

ALTER TABLE ONLY public.scheduled_job_deliveries ALTER COLUMN id SET DEFAULT nextval('public.scheduled_job_deliveries_id_seq'::regclass);

ALTER TABLE ONLY public.scheduled_job_states ALTER COLUMN id SET DEFAULT nextval('public.scheduled_job_states_id_seq'::regclass);

ALTER TABLE ONLY public.scheduled_task_executions ALTER COLUMN id SET DEFAULT nextval('public.scheduled_task_executions_id_seq'::regclass);

ALTER TABLE ONLY public.scheduled_tasks ALTER COLUMN id SET DEFAULT nextval('public.scheduled_tasks_id_seq'::regclass);

ALTER TABLE ONLY public.scheduled_volume_backup_executions ALTER COLUMN id SET DEFAULT nextval('public.scheduled_volume_backup_executions_id_seq'::regclass);

ALTER TABLE ONLY public.scheduled_volume_backup_s3_storage ALTER COLUMN id SET DEFAULT nextval('public.scheduled_volume_backup_s3_storage_id_seq'::regclass);

ALTER TABLE ONLY public.scheduled_volume_backups ALTER COLUMN id SET DEFAULT nextval('public.scheduled_volume_backups_id_seq'::regclass);

ALTER TABLE ONLY public.secret_manager_links ALTER COLUMN id SET DEFAULT nextval('public.secret_manager_links_id_seq'::regclass);

ALTER TABLE ONLY public.server_settings ALTER COLUMN id SET DEFAULT nextval('public.server_settings_id_seq'::regclass);

ALTER TABLE ONLY public.servers ALTER COLUMN id SET DEFAULT nextval('public.servers_id_seq'::regclass);

ALTER TABLE ONLY public.service_applications ALTER COLUMN id SET DEFAULT nextval('public.service_applications_id_seq'::regclass);

ALTER TABLE ONLY public.service_databases ALTER COLUMN id SET DEFAULT nextval('public.service_databases_id_seq'::regclass);

ALTER TABLE ONLY public.services ALTER COLUMN id SET DEFAULT nextval('public.services_id_seq'::regclass);

ALTER TABLE ONLY public.shared_environment_variables ALTER COLUMN id SET DEFAULT nextval('public.shared_environment_variables_id_seq'::regclass);

ALTER TABLE ONLY public.slack_notification_settings ALTER COLUMN id SET DEFAULT nextval('public.slack_notification_settings_id_seq'::regclass);

ALTER TABLE ONLY public.ssl_certificates ALTER COLUMN id SET DEFAULT nextval('public.ssl_certificates_id_seq'::regclass);

ALTER TABLE ONLY public.standalone_clickhouses ALTER COLUMN id SET DEFAULT nextval('public.standalone_clickhouses_id_seq'::regclass);

ALTER TABLE ONLY public.standalone_dockers ALTER COLUMN id SET DEFAULT nextval('public.standalone_dockers_id_seq'::regclass);

ALTER TABLE ONLY public.standalone_dragonflies ALTER COLUMN id SET DEFAULT nextval('public.standalone_dragonflies_id_seq'::regclass);

ALTER TABLE ONLY public.standalone_keydbs ALTER COLUMN id SET DEFAULT nextval('public.standalone_keydbs_id_seq'::regclass);

ALTER TABLE ONLY public.standalone_mariadbs ALTER COLUMN id SET DEFAULT nextval('public.standalone_mariadbs_id_seq'::regclass);

ALTER TABLE ONLY public.standalone_mongodbs ALTER COLUMN id SET DEFAULT nextval('public.standalone_mongodbs_id_seq'::regclass);

ALTER TABLE ONLY public.standalone_mysqls ALTER COLUMN id SET DEFAULT nextval('public.standalone_mysqls_id_seq'::regclass);

ALTER TABLE ONLY public.standalone_postgresqls ALTER COLUMN id SET DEFAULT nextval('public.standalone_postgresqls_id_seq'::regclass);

ALTER TABLE ONLY public.standalone_redis ALTER COLUMN id SET DEFAULT nextval('public.standalone_redis_id_seq'::regclass);

ALTER TABLE ONLY public.standalone_sqlites ALTER COLUMN id SET DEFAULT nextval('public.standalone_sqlites_id_seq'::regclass);

ALTER TABLE ONLY public.subscriptions ALTER COLUMN id SET DEFAULT nextval('public.subscriptions_id_seq'::regclass);

ALTER TABLE ONLY public.swarm_dockers ALTER COLUMN id SET DEFAULT nextval('public.swarm_dockers_id_seq'::regclass);

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);

ALTER TABLE ONLY public.team_invitations ALTER COLUMN id SET DEFAULT nextval('public.team_invitations_id_seq'::regclass);

ALTER TABLE ONLY public.team_user ALTER COLUMN id SET DEFAULT nextval('public.team_user_id_seq'::regclass);

ALTER TABLE ONLY public.teams ALTER COLUMN id SET DEFAULT nextval('public.teams_id_seq'::regclass);

ALTER TABLE ONLY public.telegram_notification_settings ALTER COLUMN id SET DEFAULT nextval('public.telegram_notification_settings_id_seq'::regclass);

ALTER TABLE ONLY public.telescope_entries ALTER COLUMN sequence SET DEFAULT nextval('public.telescope_entries_sequence_seq'::regclass);

ALTER TABLE ONLY public.user_changelog_reads ALTER COLUMN id SET DEFAULT nextval('public.user_changelog_reads_id_seq'::regclass);

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);

ALTER TABLE ONLY public.volume_backup_s3_replicas ALTER COLUMN id SET DEFAULT nextval('public.volume_backup_s3_replicas_id_seq'::regclass);

ALTER TABLE ONLY public.webhook_notification_settings ALTER COLUMN id SET DEFAULT nextval('public.webhook_notification_settings_id_seq'::regclass);

ALTER TABLE ONLY public.activity_log
    ADD CONSTRAINT activity_log_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.additional_destinations
    ADD CONSTRAINT additional_destinations_application_server_docker_unique UNIQUE (application_id, server_id, standalone_docker_id);

ALTER TABLE ONLY public.additional_destinations
    ADD CONSTRAINT additional_destinations_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.application_deployment_queues
    ADD CONSTRAINT application_deployment_queues_deployment_uuid_unique UNIQUE (deployment_uuid);

ALTER TABLE ONLY public.application_deployment_queues
    ADD CONSTRAINT application_deployment_queues_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.application_previews
    ADD CONSTRAINT application_previews_fqdn_unique UNIQUE (fqdn);

ALTER TABLE ONLY public.application_previews
    ADD CONSTRAINT application_previews_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.application_previews
    ADD CONSTRAINT application_previews_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.application_settings
    ADD CONSTRAINT application_settings_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.audit_events
    ADD CONSTRAINT audit_events_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.cloud_init_scripts
    ADD CONSTRAINT cloud_init_scripts_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.cloud_init_scripts
    ADD CONSTRAINT cloud_init_scripts_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.cloud_provider_tokens
    ADD CONSTRAINT cloud_provider_tokens_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.cloud_provider_tokens
    ADD CONSTRAINT cloud_provider_tokens_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.database_backup_s3_replicas
    ADD CONSTRAINT database_backup_s3_replicas_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.scheduled_database_backup_s3_storage
    ADD CONSTRAINT db_backup_s3_storage_unique UNIQUE (scheduled_database_backup_id, s3_storage_id);

ALTER TABLE ONLY public.discord_notification_settings
    ADD CONSTRAINT discord_notification_settings_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.discord_notification_settings
    ADD CONSTRAINT discord_notification_settings_team_id_unique UNIQUE (team_id);

ALTER TABLE ONLY public.dns_provider_zones
    ADD CONSTRAINT dns_provider_zones_integration_token_id_provider_zone_id_unique UNIQUE (integration_token_id, provider_zone_id);

ALTER TABLE ONLY public.dns_provider_zones
    ADD CONSTRAINT dns_provider_zones_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.dns_provider_zones
    ADD CONSTRAINT dns_provider_zones_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.docker_cleanup_executions
    ADD CONSTRAINT docker_cleanup_executions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.docker_cleanup_executions
    ADD CONSTRAINT docker_cleanup_executions_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.email_notification_settings
    ADD CONSTRAINT email_notification_settings_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.email_notification_settings
    ADD CONSTRAINT email_notification_settings_team_id_unique UNIQUE (team_id);

ALTER TABLE ONLY public.environment_variables
    ADD CONSTRAINT environment_variables_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.environments
    ADD CONSTRAINT environments_name_project_id_unique UNIQUE (name, project_id);

ALTER TABLE ONLY public.environments
    ADD CONSTRAINT environments_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.environments
    ADD CONSTRAINT environments_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.gitea_apps
    ADD CONSTRAINT gitea_apps_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.gitea_apps
    ADD CONSTRAINT gitea_apps_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.github_apps
    ADD CONSTRAINT github_apps_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.github_apps
    ADD CONSTRAINT github_apps_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.github_runner_configs
    ADD CONSTRAINT github_runner_configs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.github_runner_configs
    ADD CONSTRAINT github_runner_configs_server_id_unique UNIQUE (server_id);

ALTER TABLE ONLY public.github_runner_configs
    ADD CONSTRAINT github_runner_configs_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.github_runner_executions
    ADD CONSTRAINT github_runner_executions_github_app_id_trigger_workflow_job_id_ UNIQUE (github_app_id, trigger_workflow_job_id);

ALTER TABLE ONLY public.github_runner_executions
    ADD CONSTRAINT github_runner_executions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.github_runner_executions
    ADD CONSTRAINT github_runner_executions_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.gitlab_apps
    ADD CONSTRAINT gitlab_apps_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.gitlab_apps
    ADD CONSTRAINT gitlab_apps_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.instance_settings
    ADD CONSTRAINT instance_settings_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.integration_tokens
    ADD CONSTRAINT integration_tokens_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.integration_tokens
    ADD CONSTRAINT integration_tokens_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.local_file_volumes
    ADD CONSTRAINT local_file_volumes_mount_path_resource_id_resource_type_unique UNIQUE (mount_path, resource_id, resource_type);

ALTER TABLE ONLY public.local_file_volumes
    ADD CONSTRAINT local_file_volumes_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.local_persistent_volumes
    ADD CONSTRAINT local_persistent_volumes_name_resource_id_resource_type_unique UNIQUE (name, resource_id, resource_type);

ALTER TABLE ONLY public.local_persistent_volumes
    ADD CONSTRAINT local_persistent_volumes_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.local_persistent_volumes
    ADD CONSTRAINT local_persistent_volumes_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.managed_dns_record_references
    ADD CONSTRAINT managed_dns_record_references_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.managed_dns_record_references
    ADD CONSTRAINT managed_dns_record_references_unique UNIQUE (managed_dns_record_id, resource_type, resource_id);

ALTER TABLE ONLY public.managed_dns_records
    ADD CONSTRAINT managed_dns_records_dns_provider_zone_id_provider_record_id_uni UNIQUE (dns_provider_zone_id, provider_record_id);

ALTER TABLE ONLY public.managed_dns_records
    ADD CONSTRAINT managed_dns_records_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.managed_dns_records
    ADD CONSTRAINT managed_dns_records_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.notification_throttles
    ADD CONSTRAINT notification_throttles_notifiable_type_notifiable_id_notificati UNIQUE (notifiable_type, notifiable_id, notification);

ALTER TABLE ONLY public.notification_throttles
    ADD CONSTRAINT notification_throttles_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.oauth_identities
    ADD CONSTRAINT oauth_identities_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.oauth_identities
    ADD CONSTRAINT oauth_identity_provider_issuer_user_unique UNIQUE (provider, issuer, provider_user_id);

ALTER TABLE ONLY public.oauth_settings
    ADD CONSTRAINT oauth_settings_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.oauth_settings
    ADD CONSTRAINT oauth_settings_provider_unique UNIQUE (provider);

ALTER TABLE ONLY public.passkeys
    ADD CONSTRAINT passkeys_credential_id_unique UNIQUE (credential_id);

ALTER TABLE ONLY public.passkeys
    ADD CONSTRAINT passkeys_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (email);

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_token_unique UNIQUE (token);

ALTER TABLE ONLY public.private_keys
    ADD CONSTRAINT private_keys_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.private_keys
    ADD CONSTRAINT private_keys_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.project_settings
    ADD CONSTRAINT project_settings_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.pushover_notification_settings
    ADD CONSTRAINT pushover_notification_settings_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.pushover_notification_settings
    ADD CONSTRAINT pushover_notification_settings_team_id_unique UNIQUE (team_id);

ALTER TABLE ONLY public.resource_links
    ADD CONSTRAINT resource_links_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.resource_links
    ADD CONSTRAINT resource_links_unique_direction UNIQUE (environment_id, source_type, source_id, target_type, target_id);

ALTER TABLE ONLY public.resource_links
    ADD CONSTRAINT resource_links_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.s3_storages
    ADD CONSTRAINT s3_storages_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.s3_storages
    ADD CONSTRAINT s3_storages_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.scheduled_database_backup_executions
    ADD CONSTRAINT scheduled_database_backup_executions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.scheduled_database_backup_executions
    ADD CONSTRAINT scheduled_database_backup_executions_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.scheduled_database_backup_s3_storage
    ADD CONSTRAINT scheduled_database_backup_s3_storage_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.scheduled_database_backups
    ADD CONSTRAINT scheduled_database_backups_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.scheduled_database_backups
    ADD CONSTRAINT scheduled_database_backups_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.scheduled_job_deliveries
    ADD CONSTRAINT scheduled_job_deliveries_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.scheduled_job_deliveries
    ADD CONSTRAINT scheduled_job_deliveries_schedule_key_scheduled_for_unique UNIQUE (schedule_key, scheduled_for);

ALTER TABLE ONLY public.scheduled_job_deliveries
    ADD CONSTRAINT scheduled_job_deliveries_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.scheduled_job_states
    ADD CONSTRAINT scheduled_job_states_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.scheduled_job_states
    ADD CONSTRAINT scheduled_job_states_schedule_key_unique UNIQUE (schedule_key);

ALTER TABLE ONLY public.scheduled_job_states
    ADD CONSTRAINT scheduled_job_states_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.scheduled_task_executions
    ADD CONSTRAINT scheduled_task_executions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.scheduled_task_executions
    ADD CONSTRAINT scheduled_task_executions_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.scheduled_tasks
    ADD CONSTRAINT scheduled_tasks_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.scheduled_tasks
    ADD CONSTRAINT scheduled_tasks_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.scheduled_volume_backup_executions
    ADD CONSTRAINT scheduled_volume_backup_executions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.scheduled_volume_backup_executions
    ADD CONSTRAINT scheduled_volume_backup_executions_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.scheduled_volume_backup_s3_storage
    ADD CONSTRAINT scheduled_volume_backup_s3_storage_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.scheduled_volume_backups
    ADD CONSTRAINT scheduled_volume_backups_backupable_type_backupable_id_unique UNIQUE (backupable_type, backupable_id);

ALTER TABLE ONLY public.scheduled_volume_backups
    ADD CONSTRAINT scheduled_volume_backups_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.scheduled_volume_backups
    ADD CONSTRAINT scheduled_volume_backups_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.secret_manager_links
    ADD CONSTRAINT secret_manager_links_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.secret_manager_links
    ADD CONSTRAINT secret_manager_links_resourceable_type_resourceable_id_unique UNIQUE (resourceable_type, resourceable_id);

ALTER TABLE ONLY public.secret_manager_links
    ADD CONSTRAINT secret_manager_links_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.server_settings
    ADD CONSTRAINT server_settings_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.servers
    ADD CONSTRAINT servers_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.servers
    ADD CONSTRAINT servers_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.service_applications
    ADD CONSTRAINT service_applications_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.service_applications
    ADD CONSTRAINT service_applications_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.service_databases
    ADD CONSTRAINT service_databases_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.service_databases
    ADD CONSTRAINT service_databases_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.shared_environment_variables
    ADD CONSTRAINT shared_environment_variables_key_environment_id_team_id_unique UNIQUE (key, environment_id, team_id);

ALTER TABLE ONLY public.shared_environment_variables
    ADD CONSTRAINT shared_environment_variables_key_project_id_team_id_unique UNIQUE (key, project_id, team_id);

ALTER TABLE ONLY public.shared_environment_variables
    ADD CONSTRAINT shared_environment_variables_key_server_id_team_id_unique UNIQUE (key, server_id, team_id);

ALTER TABLE ONLY public.shared_environment_variables
    ADD CONSTRAINT shared_environment_variables_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.slack_notification_settings
    ADD CONSTRAINT slack_notification_settings_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.slack_notification_settings
    ADD CONSTRAINT slack_notification_settings_team_id_unique UNIQUE (team_id);

ALTER TABLE ONLY public.ssl_certificates
    ADD CONSTRAINT ssl_certificates_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.standalone_clickhouses
    ADD CONSTRAINT standalone_clickhouses_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.standalone_clickhouses
    ADD CONSTRAINT standalone_clickhouses_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.standalone_dockers
    ADD CONSTRAINT standalone_dockers_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.standalone_dockers
    ADD CONSTRAINT standalone_dockers_server_id_network_unique UNIQUE (server_id, network);

ALTER TABLE ONLY public.standalone_dockers
    ADD CONSTRAINT standalone_dockers_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.standalone_dragonflies
    ADD CONSTRAINT standalone_dragonflies_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.standalone_dragonflies
    ADD CONSTRAINT standalone_dragonflies_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.standalone_keydbs
    ADD CONSTRAINT standalone_keydbs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.standalone_keydbs
    ADD CONSTRAINT standalone_keydbs_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.standalone_mariadbs
    ADD CONSTRAINT standalone_mariadbs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.standalone_mariadbs
    ADD CONSTRAINT standalone_mariadbs_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.standalone_mongodbs
    ADD CONSTRAINT standalone_mongodbs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.standalone_mongodbs
    ADD CONSTRAINT standalone_mongodbs_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.standalone_mysqls
    ADD CONSTRAINT standalone_mysqls_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.standalone_mysqls
    ADD CONSTRAINT standalone_mysqls_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.standalone_postgresqls
    ADD CONSTRAINT standalone_postgresqls_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.standalone_postgresqls
    ADD CONSTRAINT standalone_postgresqls_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.standalone_redis
    ADD CONSTRAINT standalone_redis_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.standalone_redis
    ADD CONSTRAINT standalone_redis_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.standalone_sqlites
    ADD CONSTRAINT standalone_sqlites_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.standalone_sqlites
    ADD CONSTRAINT standalone_sqlites_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.swarm_dockers
    ADD CONSTRAINT swarm_dockers_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.swarm_dockers
    ADD CONSTRAINT swarm_dockers_server_id_network_unique UNIQUE (server_id, network);

ALTER TABLE ONLY public.swarm_dockers
    ADD CONSTRAINT swarm_dockers_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.taggables
    ADD CONSTRAINT taggable_unique UNIQUE (tag_id, taggable_id, taggable_type);

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_team_id_name_unique UNIQUE (team_id, name);

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.team_invitations
    ADD CONSTRAINT team_invitations_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.team_invitations
    ADD CONSTRAINT team_invitations_team_id_email_unique UNIQUE (team_id, email);

ALTER TABLE ONLY public.team_invitations
    ADD CONSTRAINT team_invitations_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.team_user
    ADD CONSTRAINT team_user_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.team_user
    ADD CONSTRAINT team_user_team_id_user_id_unique UNIQUE (team_id, user_id);

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.telegram_notification_settings
    ADD CONSTRAINT telegram_notification_settings_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.telegram_notification_settings
    ADD CONSTRAINT telegram_notification_settings_team_id_unique UNIQUE (team_id);

ALTER TABLE ONLY public.telescope_entries
    ADD CONSTRAINT telescope_entries_pkey PRIMARY KEY (sequence);

ALTER TABLE ONLY public.telescope_entries_tags
    ADD CONSTRAINT telescope_entries_tags_pkey PRIMARY KEY (entry_uuid, tag);

ALTER TABLE ONLY public.telescope_entries
    ADD CONSTRAINT telescope_entries_uuid_unique UNIQUE (uuid);

ALTER TABLE ONLY public.telescope_monitoring
    ADD CONSTRAINT telescope_monitoring_pkey PRIMARY KEY (tag);

ALTER TABLE ONLY public.user_changelog_reads
    ADD CONSTRAINT user_changelog_reads_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.user_changelog_reads
    ADD CONSTRAINT user_changelog_reads_user_id_release_tag_unique UNIQUE (user_id, release_tag);

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.volume_backup_s3_replicas
    ADD CONSTRAINT volume_backup_s3_replicas_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.scheduled_volume_backup_s3_storage
    ADD CONSTRAINT volume_backup_s3_storage_unique UNIQUE (scheduled_volume_backup_id, s3_storage_id);

ALTER TABLE ONLY public.webhook_notification_settings
    ADD CONSTRAINT webhook_notification_settings_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.webhook_notification_settings
    ADD CONSTRAINT webhook_notification_settings_team_id_unique UNIQUE (team_id);

CREATE INDEX activity_log_log_name_index ON public.activity_log USING btree (log_name);

CREATE INDEX application_deployment_queues_parent_deployment_uuid_index ON public.application_deployment_queues USING btree (parent_deployment_uuid);

CREATE INDEX application_previews_application_id_index ON public.application_previews USING btree (application_id);

CREATE INDEX application_settings_application_id_index ON public.application_settings USING btree (application_id);

CREATE INDEX applications_destination_type_destination_id_index ON public.applications USING btree (destination_type, destination_id);

CREATE INDEX applications_source_type_source_id_index ON public.applications USING btree (source_type, source_id);

CREATE INDEX audit_events_created_at_index ON public.audit_events USING btree (created_at);

CREATE INDEX audit_events_level_index ON public.audit_events USING btree (level);

CREATE INDEX audit_events_team_id_action_created_at_id_index ON public.audit_events USING btree (team_id, action, created_at, id);

CREATE INDEX audit_events_team_id_actor_id_created_at_index ON public.audit_events USING btree (team_id, actor_id, created_at);

CREATE INDEX audit_events_team_id_created_at_id_index ON public.audit_events USING btree (team_id, created_at, id);

CREATE INDEX audit_events_team_id_resource_type_resource_uuid_created_at_ind ON public.audit_events USING btree (team_id, resource_type, resource_uuid, created_at);

CREATE INDEX audit_events_team_id_source_created_at_id_index ON public.audit_events USING btree (team_id, source, created_at, id);

CREATE INDEX causer ON public.activity_log USING btree (causer_type, causer_id);

CREATE INDEX cloud_init_scripts_team_id_index ON public.cloud_init_scripts USING btree (team_id);

CREATE INDEX cloud_provider_tokens_team_id_provider_index ON public.cloud_provider_tokens USING btree (team_id, provider);

CREATE INDEX database_backup_s3_replicas_execution_id_index ON public.database_backup_s3_replicas USING btree (execution_id);

CREATE INDEX dns_provider_zones_name_index ON public.dns_provider_zones USING btree (name);

CREATE INDEX environment_variables_resourceable_type_resourceable_id_index ON public.environment_variables USING btree (resourceable_type, resourceable_id);

CREATE INDEX github_runner_executions_github_app_id_runner_name_index ON public.github_runner_executions USING btree (github_app_id, runner_name);

CREATE INDEX github_runner_executions_github_app_id_status_index ON public.github_runner_executions USING btree (github_app_id, status);

CREATE INDEX github_runner_executions_github_runner_config_id_status_index ON public.github_runner_executions USING btree (github_runner_config_id, status);

CREATE INDEX idx_activity_type_uuid ON public.activity_log USING gin (properties jsonb_path_ops);

CREATE INDEX idx_applications_environment_id_all ON public.applications USING btree (environment_id);

CREATE INDEX idx_cloud_init_scripts_team_id ON public.cloud_init_scripts USING btree (team_id);

CREATE INDEX idx_cloud_provider_tokens_team_id ON public.cloud_provider_tokens USING btree (team_id);

CREATE INDEX idx_deployment_queues_app_created_id ON public.application_deployment_queues USING btree (application_id, created_at DESC, id DESC);

CREATE INDEX idx_deployment_queues_app_id ON public.application_deployment_queues USING btree (application_id, id);

CREATE INDEX idx_deployment_queues_app_status_pr_created ON public.application_deployment_queues USING btree (application_id, status, pull_request_id, created_at);

CREATE INDEX idx_deployment_queues_status_server ON public.application_deployment_queues USING btree (status, server_id);

CREATE INDEX idx_docker_cleanup_executions_server_created_at ON public.docker_cleanup_executions USING btree (server_id, created_at DESC);

CREATE INDEX idx_docker_cleanup_executions_unfinished_status_created ON public.docker_cleanup_executions USING btree (status, created_at) WHERE (finished_at IS NULL);

CREATE INDEX idx_environments_project_id ON public.environments USING btree (project_id);

CREATE INDEX idx_github_runner_executions_status_server_id ON public.github_runner_executions USING btree (status, server_id);

CREATE INDEX idx_private_keys_team_id ON public.private_keys USING btree (team_id);

CREATE INDEX idx_projects_team_id ON public.projects USING btree (team_id);

CREATE INDEX idx_server_settings_server_id ON public.server_settings USING btree (server_id);

CREATE INDEX idx_servers_private_key_id_active ON public.servers USING btree (private_key_id) WHERE (deleted_at IS NULL);

CREATE INDEX idx_servers_team_id ON public.servers USING btree (team_id);

CREATE INDEX idx_subscriptions_team_id ON public.subscriptions USING btree (team_id);

CREATE INDEX idx_team_user_user_id ON public.team_user USING btree (user_id);

CREATE INDEX integration_tokens_team_id_provider_index ON public.integration_tokens USING btree (team_id, provider);

CREATE INDEX local_file_volumes_resource_type_resource_id_index ON public.local_file_volumes USING btree (resource_type, resource_id);

CREATE INDEX local_persistent_volumes_resource_type_resource_id_index ON public.local_persistent_volumes USING btree (resource_type, resource_id);

CREATE INDEX managed_dns_record_references_resource_type_resource_id_index ON public.managed_dns_record_references USING btree (resource_type, resource_id);

CREATE INDEX managed_dns_records_team_id_name_index ON public.managed_dns_records USING btree (team_id, name);

CREATE INDEX notification_throttles_notifiable_type_notifiable_id_index ON public.notification_throttles USING btree (notifiable_type, notifiable_id);

CREATE INDEX oauth_identities_email_index ON public.oauth_identities USING btree (email);

CREATE INDEX passkeys_user_id_index ON public.passkeys USING btree (user_id);

CREATE INDEX personal_access_tokens_expiration_warning_index ON public.personal_access_tokens USING btree (expires_at, api_token_expiration_warning_sent_at);

CREATE INDEX personal_access_tokens_tokenable_type_tokenable_id_index ON public.personal_access_tokens USING btree (tokenable_type, tokenable_id);

CREATE INDEX resource_links_source_type_source_id_index ON public.resource_links USING btree (source_type, source_id);

CREATE INDEX resource_links_target_type_target_id_index ON public.resource_links USING btree (target_type, target_id);

CREATE INDEX scheduled_database_backups_database_type_database_id_index ON public.scheduled_database_backups USING btree (database_type, database_id);

CREATE INDEX scheduled_db_backup_executions_backup_id_created_at_index ON public.scheduled_database_backup_executions USING btree (scheduled_database_backup_id, created_at);

CREATE INDEX scheduled_job_deliveries_status_created_at_index ON public.scheduled_job_deliveries USING btree (status, created_at);

CREATE INDEX scheduled_task_executions_task_id_created_at_index ON public.scheduled_task_executions USING btree (scheduled_task_id, created_at);

CREATE INDEX scheduled_volume_executions_backup_created_index ON public.scheduled_volume_backup_executions USING btree (scheduled_volume_backup_id, created_at);

CREATE INDEX scheduled_volume_executions_recovery_index ON public.scheduled_volume_backup_executions USING btree (stop_recovery_pending, s3_cleanup_pending, recovery_needs_attention);

CREATE INDEX servers_sentinel_updated_at_index ON public.servers USING btree (sentinel_updated_at);

CREATE INDEX service_applications_service_id_index ON public.service_applications USING btree (service_id);

CREATE INDEX service_databases_service_id_index ON public.service_databases USING btree (service_id);

CREATE INDEX services_destination_type_destination_id_index ON public.services USING btree (destination_type, destination_id);

CREATE INDEX services_server_id_index ON public.services USING btree (server_id);

CREATE INDEX sessions_last_activity_index ON public.sessions USING btree (last_activity);

CREATE INDEX sessions_user_id_index ON public.sessions USING btree (user_id);

CREATE INDEX standalone_clickhouses_destination_type_destination_id_index ON public.standalone_clickhouses USING btree (destination_type, destination_id);

CREATE INDEX standalone_dragonflies_destination_type_destination_id_index ON public.standalone_dragonflies USING btree (destination_type, destination_id);

CREATE INDEX standalone_keydbs_destination_type_destination_id_index ON public.standalone_keydbs USING btree (destination_type, destination_id);

CREATE INDEX standalone_mariadbs_destination_type_destination_id_index ON public.standalone_mariadbs USING btree (destination_type, destination_id);

CREATE INDEX standalone_mongodbs_destination_type_destination_id_index ON public.standalone_mongodbs USING btree (destination_type, destination_id);

CREATE INDEX standalone_mysqls_destination_type_destination_id_index ON public.standalone_mysqls USING btree (destination_type, destination_id);

CREATE INDEX standalone_postgresqls_destination_type_destination_id_index ON public.standalone_postgresqls USING btree (destination_type, destination_id);

CREATE INDEX standalone_redis_destination_type_destination_id_index ON public.standalone_redis USING btree (destination_type, destination_id);

CREATE INDEX standalone_sqlites_destination_type_destination_id_index ON public.standalone_sqlites USING btree (destination_type, destination_id);

CREATE INDEX subject ON public.activity_log USING btree (subject_type, subject_id);

CREATE INDEX subscriptions_ended_at_index ON public.subscriptions USING btree (ended_at);

CREATE INDEX swarm_dockers_server_id_index ON public.swarm_dockers USING btree (server_id);

CREATE INDEX telescope_entries_batch_id_index ON public.telescope_entries USING btree (batch_id);

CREATE INDEX telescope_entries_created_at_index ON public.telescope_entries USING btree (created_at);

CREATE INDEX telescope_entries_family_hash_index ON public.telescope_entries USING btree (family_hash);

CREATE INDEX telescope_entries_tags_tag_index ON public.telescope_entries_tags USING btree (tag);

CREATE INDEX telescope_entries_type_should_display_on_index_index ON public.telescope_entries USING btree (type, should_display_on_index);

CREATE INDEX user_changelog_reads_release_tag_index ON public.user_changelog_reads USING btree (release_tag);

CREATE INDEX user_changelog_reads_user_id_index ON public.user_changelog_reads USING btree (user_id);

CREATE INDEX volume_backup_s3_replicas_execution_id_index ON public.volume_backup_s3_replicas USING btree (execution_id);

ALTER TABLE ONLY public.additional_destinations
    ADD CONSTRAINT additional_destinations_application_id_foreign FOREIGN KEY (application_id) REFERENCES public.applications(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.additional_destinations
    ADD CONSTRAINT additional_destinations_server_id_foreign FOREIGN KEY (server_id) REFERENCES public.servers(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.additional_destinations
    ADD CONSTRAINT additional_destinations_standalone_docker_id_foreign FOREIGN KEY (standalone_docker_id) REFERENCES public.standalone_dockers(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.cloud_init_scripts
    ADD CONSTRAINT cloud_init_scripts_team_id_foreign FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.cloud_provider_tokens
    ADD CONSTRAINT cloud_provider_tokens_team_id_foreign FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.database_backup_s3_replicas
    ADD CONSTRAINT db_backup_s3_replicas_execution_fk FOREIGN KEY (execution_id) REFERENCES public.scheduled_database_backup_executions(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.database_backup_s3_replicas
    ADD CONSTRAINT db_backup_s3_replicas_storage_fk FOREIGN KEY (s3_storage_id) REFERENCES public.s3_storages(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.scheduled_database_backup_s3_storage
    ADD CONSTRAINT db_backup_s3_storage_backup_fk FOREIGN KEY (scheduled_database_backup_id) REFERENCES public.scheduled_database_backups(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.scheduled_database_backup_s3_storage
    ADD CONSTRAINT db_backup_s3_storage_storage_fk FOREIGN KEY (s3_storage_id) REFERENCES public.s3_storages(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.discord_notification_settings
    ADD CONSTRAINT discord_notification_settings_team_id_foreign FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.dns_provider_zones
    ADD CONSTRAINT dns_provider_zones_integration_token_id_foreign FOREIGN KEY (integration_token_id) REFERENCES public.integration_tokens(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.email_notification_settings
    ADD CONSTRAINT email_notification_settings_team_id_foreign FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.github_runner_configs
    ADD CONSTRAINT github_runner_configs_github_app_id_foreign FOREIGN KEY (github_app_id) REFERENCES public.github_apps(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.github_runner_configs
    ADD CONSTRAINT github_runner_configs_server_id_foreign FOREIGN KEY (server_id) REFERENCES public.servers(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.github_runner_executions
    ADD CONSTRAINT github_runner_executions_github_app_id_foreign FOREIGN KEY (github_app_id) REFERENCES public.github_apps(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.github_runner_executions
    ADD CONSTRAINT github_runner_executions_github_runner_config_id_foreign FOREIGN KEY (github_runner_config_id) REFERENCES public.github_runner_configs(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.github_runner_executions
    ADD CONSTRAINT github_runner_executions_server_id_foreign FOREIGN KEY (server_id) REFERENCES public.servers(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.instance_settings
    ADD CONSTRAINT instance_settings_avatar_s3_storage_id_foreign FOREIGN KEY (avatar_s3_storage_id) REFERENCES public.s3_storages(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.instance_settings
    ADD CONSTRAINT instance_settings_file_download_s3_storage_id_foreign FOREIGN KEY (file_download_s3_storage_id) REFERENCES public.s3_storages(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.integration_tokens
    ADD CONSTRAINT integration_tokens_team_id_foreign FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.local_persistent_volumes
    ADD CONSTRAINT local_persistent_volumes_standalone_sqlite_id_foreign FOREIGN KEY (standalone_sqlite_id) REFERENCES public.standalone_sqlites(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.managed_dns_record_references
    ADD CONSTRAINT managed_dns_record_references_managed_dns_record_id_foreign FOREIGN KEY (managed_dns_record_id) REFERENCES public.managed_dns_records(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.managed_dns_records
    ADD CONSTRAINT managed_dns_records_dns_provider_zone_id_foreign FOREIGN KEY (dns_provider_zone_id) REFERENCES public.dns_provider_zones(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.managed_dns_records
    ADD CONSTRAINT managed_dns_records_integration_token_id_foreign FOREIGN KEY (integration_token_id) REFERENCES public.integration_tokens(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.managed_dns_records
    ADD CONSTRAINT managed_dns_records_team_id_foreign FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.oauth_identities
    ADD CONSTRAINT oauth_identities_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.passkeys
    ADD CONSTRAINT passkeys_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_icon_s3_storage_id_foreign FOREIGN KEY (icon_s3_storage_id) REFERENCES public.s3_storages(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.pushover_notification_settings
    ADD CONSTRAINT pushover_notification_settings_team_id_foreign FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.resource_links
    ADD CONSTRAINT resource_links_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.resource_links
    ADD CONSTRAINT resource_links_environment_id_foreign FOREIGN KEY (environment_id) REFERENCES public.environments(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.scheduled_volume_backup_executions
    ADD CONSTRAINT scheduled_volume_backup_executions_s3_storage_id_foreign FOREIGN KEY (s3_storage_id) REFERENCES public.s3_storages(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.scheduled_volume_backup_executions
    ADD CONSTRAINT scheduled_volume_backup_executions_scheduled_volume_backup_id_f FOREIGN KEY (scheduled_volume_backup_id) REFERENCES public.scheduled_volume_backups(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.scheduled_volume_backups
    ADD CONSTRAINT scheduled_volume_backups_s3_storage_id_foreign FOREIGN KEY (s3_storage_id) REFERENCES public.s3_storages(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.scheduled_volume_backups
    ADD CONSTRAINT scheduled_volume_backups_team_id_foreign FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.secret_manager_links
    ADD CONSTRAINT secret_manager_links_integration_token_id_foreign FOREIGN KEY (integration_token_id) REFERENCES public.integration_tokens(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.server_settings
    ADD CONSTRAINT server_settings_cloudflare_tunnel_integration_token_id_foreign FOREIGN KEY (cloudflare_tunnel_integration_token_id) REFERENCES public.integration_tokens(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.servers
    ADD CONSTRAINT servers_cloud_provider_token_id_foreign FOREIGN KEY (cloud_provider_token_id) REFERENCES public.cloud_provider_tokens(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.shared_environment_variables
    ADD CONSTRAINT shared_environment_variables_environment_id_foreign FOREIGN KEY (environment_id) REFERENCES public.environments(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.shared_environment_variables
    ADD CONSTRAINT shared_environment_variables_project_id_foreign FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.shared_environment_variables
    ADD CONSTRAINT shared_environment_variables_server_id_foreign FOREIGN KEY (server_id) REFERENCES public.servers(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.shared_environment_variables
    ADD CONSTRAINT shared_environment_variables_team_id_foreign FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.slack_notification_settings
    ADD CONSTRAINT slack_notification_settings_team_id_foreign FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.ssl_certificates
    ADD CONSTRAINT ssl_certificates_server_id_foreign FOREIGN KEY (server_id) REFERENCES public.servers(id);

ALTER TABLE ONLY public.taggables
    ADD CONSTRAINT taggables_tag_id_foreign FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_team_id_foreign FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.team_invitations
    ADD CONSTRAINT team_invitations_team_id_foreign FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_avatar_s3_storage_id_foreign FOREIGN KEY (avatar_s3_storage_id) REFERENCES public.s3_storages(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.telegram_notification_settings
    ADD CONSTRAINT telegram_notification_settings_team_id_foreign FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.telescope_entries_tags
    ADD CONSTRAINT telescope_entries_tags_entry_uuid_foreign FOREIGN KEY (entry_uuid) REFERENCES public.telescope_entries(uuid) ON DELETE CASCADE;

ALTER TABLE ONLY public.user_changelog_reads
    ADD CONSTRAINT user_changelog_reads_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_avatar_s3_storage_id_foreign FOREIGN KEY (avatar_s3_storage_id) REFERENCES public.s3_storages(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.volume_backup_s3_replicas
    ADD CONSTRAINT volume_backup_s3_replicas_execution_fk FOREIGN KEY (execution_id) REFERENCES public.scheduled_volume_backup_executions(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.volume_backup_s3_replicas
    ADD CONSTRAINT volume_backup_s3_replicas_storage_fk FOREIGN KEY (s3_storage_id) REFERENCES public.s3_storages(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.scheduled_volume_backup_s3_storage
    ADD CONSTRAINT volume_backup_s3_storage_backup_fk FOREIGN KEY (scheduled_volume_backup_id) REFERENCES public.scheduled_volume_backups(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.scheduled_volume_backup_s3_storage
    ADD CONSTRAINT volume_backup_s3_storage_storage_fk FOREIGN KEY (s3_storage_id) REFERENCES public.s3_storages(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.webhook_notification_settings
    ADD CONSTRAINT webhook_notification_settings_team_id_foreign FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE CASCADE;

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

INSERT INTO public.migrations VALUES (1, '2014_10_12_000000_create_users_table', 1);
INSERT INTO public.migrations VALUES (2, '2014_10_12_100000_create_password_reset_tokens_table', 1);
INSERT INTO public.migrations VALUES (3, '2014_10_12_200000_add_two_factor_columns_to_users_table', 1);
INSERT INTO public.migrations VALUES (4, '2018_08_08_100000_create_telescope_entries_table', 1);
INSERT INTO public.migrations VALUES (5, '2019_12_14_000001_create_personal_access_tokens_table', 1);
INSERT INTO public.migrations VALUES (6, '2023_03_20_112410_create_activity_log_table', 1);
INSERT INTO public.migrations VALUES (7, '2023_03_20_112411_add_event_column_to_activity_log_table', 1);
INSERT INTO public.migrations VALUES (8, '2023_03_20_112412_add_batch_uuid_column_to_activity_log_table', 1);
INSERT INTO public.migrations VALUES (9, '2023_03_20_112809_create_sessions_table', 1);
INSERT INTO public.migrations VALUES (10, '2023_03_20_112811_create_teams_table', 1);
INSERT INTO public.migrations VALUES (11, '2023_03_20_112812_create_team_user_table', 1);
INSERT INTO public.migrations VALUES (12, '2023_03_20_112813_create_team_invitations_table', 1);
INSERT INTO public.migrations VALUES (13, '2023_03_20_112814_create_instance_settings_table', 1);
INSERT INTO public.migrations VALUES (14, '2023_03_24_140711_create_servers_table', 1);
INSERT INTO public.migrations VALUES (15, '2023_03_24_140712_create_server_settings_table', 1);
INSERT INTO public.migrations VALUES (16, '2023_03_24_140853_create_private_keys_table', 1);
INSERT INTO public.migrations VALUES (17, '2023_03_27_075351_create_projects_table', 1);
INSERT INTO public.migrations VALUES (18, '2023_03_27_075443_create_project_settings_table', 1);
INSERT INTO public.migrations VALUES (19, '2023_03_27_075444_create_environments_table', 1);
INSERT INTO public.migrations VALUES (20, '2023_03_27_081716_create_applications_table', 1);
INSERT INTO public.migrations VALUES (21, '2023_03_27_081717_create_application_settings_table', 1);
INSERT INTO public.migrations VALUES (22, '2023_03_27_081718_create_application_previews_table', 1);
INSERT INTO public.migrations VALUES (23, '2023_03_27_083621_create_services_table', 1);
INSERT INTO public.migrations VALUES (24, '2023_03_27_085020_create_standalone_dockers_table', 1);
INSERT INTO public.migrations VALUES (25, '2023_03_27_085022_create_swarm_dockers_table', 1);
INSERT INTO public.migrations VALUES (26, '2023_03_28_062150_create_kubernetes_table', 1);
INSERT INTO public.migrations VALUES (27, '2023_03_28_083723_create_github_apps_table', 1);
INSERT INTO public.migrations VALUES (28, '2023_03_28_083726_create_gitlab_apps_table', 1);
INSERT INTO public.migrations VALUES (29, '2023_04_03_111012_create_local_persistent_volumes_table', 1);
INSERT INTO public.migrations VALUES (30, '2023_05_04_194548_create_environment_variables_table', 1);
INSERT INTO public.migrations VALUES (31, '2023_05_17_104039_create_failed_jobs_table', 1);
INSERT INTO public.migrations VALUES (32, '2023_05_24_083426_create_application_deployment_queues_table', 1);
INSERT INTO public.migrations VALUES (33, '2023_06_22_131459_move_wildcard_to_server', 1);
INSERT INTO public.migrations VALUES (34, '2023_06_23_084605_remove_wildcard_domain_from_instancesettings', 1);
INSERT INTO public.migrations VALUES (35, '2023_06_23_110548_next_channel_updates', 1);
INSERT INTO public.migrations VALUES (36, '2023_06_23_114131_change_env_var_value_length', 1);
INSERT INTO public.migrations VALUES (37, '2023_06_23_114132_remove_default_redirect_from_instance_settings', 1);
INSERT INTO public.migrations VALUES (38, '2023_06_23_114133_use_application_deployment_queues_as_activity', 1);
INSERT INTO public.migrations VALUES (39, '2023_06_23_114134_add_disk_usage_percentage_to_servers', 1);
INSERT INTO public.migrations VALUES (40, '2023_07_13_115117_create_subscriptions_table', 1);
INSERT INTO public.migrations VALUES (41, '2023_07_13_120719_create_webhooks_table', 1);
INSERT INTO public.migrations VALUES (42, '2023_07_13_120721_add_license_to_instance_settings', 1);
INSERT INTO public.migrations VALUES (43, '2023_07_27_182013_smtp_discord_schemaless_to_normal', 1);
INSERT INTO public.migrations VALUES (44, '2023_08_06_142951_add_description_field_to_applications_table', 1);
INSERT INTO public.migrations VALUES (45, '2023_08_06_142952_remove_foreignId_environment_variables', 1);
INSERT INTO public.migrations VALUES (46, '2023_08_06_142954_add_readonly_localpersistentvolumes', 1);
INSERT INTO public.migrations VALUES (47, '2023_08_07_073651_create_s3_storages_table', 1);
INSERT INTO public.migrations VALUES (48, '2023_08_07_142950_create_standalone_postgresqls_table', 1);
INSERT INTO public.migrations VALUES (49, '2023_08_08_150103_create_scheduled_database_backups_table', 1);
INSERT INTO public.migrations VALUES (50, '2023_08_10_113306_create_scheduled_database_backup_executions_table', 1);
INSERT INTO public.migrations VALUES (51, '2023_08_10_201311_add_backup_notifications_to_teams', 1);
INSERT INTO public.migrations VALUES (52, '2023_08_11_190528_add_dockerfile_to_applications_table', 1);
INSERT INTO public.migrations VALUES (53, '2023_08_15_095902_create_waitlists_table', 1);
INSERT INTO public.migrations VALUES (54, '2023_08_15_111125_update_users_table', 1);
INSERT INTO public.migrations VALUES (55, '2023_08_15_111126_update_servers_add_unreachable_count_table', 1);
INSERT INTO public.migrations VALUES (56, '2023_08_22_071048_add_boarding_to_teams', 1);
INSERT INTO public.migrations VALUES (57, '2023_08_22_071049_update_webhooks_type', 1);
INSERT INTO public.migrations VALUES (58, '2023_08_22_071050_update_subscriptions_stripe', 1);
INSERT INTO public.migrations VALUES (59, '2023_08_22_071051_add_stripe_plan_to_subscriptions', 1);
INSERT INTO public.migrations VALUES (60, '2023_08_22_071052_add_resend_as_email', 1);
INSERT INTO public.migrations VALUES (61, '2023_08_22_071053_add_resend_as_email_to_teams', 1);
INSERT INTO public.migrations VALUES (62, '2023_08_22_071054_add_stripe_reasons', 1);
INSERT INTO public.migrations VALUES (63, '2023_08_22_071055_add_discord_notifications_to_teams', 1);
INSERT INTO public.migrations VALUES (64, '2023_08_22_071056_update_telegram_notifications', 1);
INSERT INTO public.migrations VALUES (65, '2023_08_22_071057_add_nixpkgsarchive_to_applications', 1);
INSERT INTO public.migrations VALUES (66, '2023_08_22_071058_add_nixpkgsarchive_to_applications_remove', 1);
INSERT INTO public.migrations VALUES (67, '2023_08_22_071059_add_stripe_trial_ended', 1);
INSERT INTO public.migrations VALUES (68, '2023_08_22_071060_change_invitation_link_length', 1);
INSERT INTO public.migrations VALUES (69, '2023_09_20_082541_update_services_table', 1);
INSERT INTO public.migrations VALUES (70, '2023_09_20_082733_create_service_databases_table', 1);
INSERT INTO public.migrations VALUES (71, '2023_09_20_082737_create_service_applications_table', 1);
INSERT INTO public.migrations VALUES (72, '2023_09_20_083549_update_environment_variables_table', 1);
INSERT INTO public.migrations VALUES (73, '2023_09_22_185356_create_local_file_volumes_table', 1);
INSERT INTO public.migrations VALUES (74, '2023_09_23_111808_update_servers_with_cloudflared', 1);
INSERT INTO public.migrations VALUES (75, '2023_09_23_111809_remove_destination_from_services_table', 1);
INSERT INTO public.migrations VALUES (76, '2023_09_23_111811_update_service_applications_table', 1);
INSERT INTO public.migrations VALUES (77, '2023_09_23_111812_update_service_databases_table', 1);
INSERT INTO public.migrations VALUES (78, '2023_09_23_111813_update_users_databases_table', 1);
INSERT INTO public.migrations VALUES (79, '2023_09_23_111814_update_local_file_volumes_table', 1);
INSERT INTO public.migrations VALUES (80, '2023_09_23_111815_add_healthcheck_disable_to_apps_table', 1);
INSERT INTO public.migrations VALUES (81, '2023_09_23_111816_add_destination_to_services_table', 1);
INSERT INTO public.migrations VALUES (82, '2023_09_23_111817_use_instance_email_settings_by_default', 1);
INSERT INTO public.migrations VALUES (83, '2023_09_23_111818_set_notifications_on_by_default', 1);
INSERT INTO public.migrations VALUES (84, '2023_09_23_111819_add_server_emails', 1);
INSERT INTO public.migrations VALUES (85, '2023_10_08_111819_add_server_unreachable_count', 1);
INSERT INTO public.migrations VALUES (86, '2023_10_10_100320_update_s3_storages_table', 1);
INSERT INTO public.migrations VALUES (87, '2023_10_10_113144_add_dockerfile_location_applications_table', 1);
INSERT INTO public.migrations VALUES (88, '2023_10_12_132430_create_standalone_redis_table', 1);
INSERT INTO public.migrations VALUES (89, '2023_10_12_132431_add_standalone_redis_to_environment_variables_table', 1);
INSERT INTO public.migrations VALUES (90, '2023_10_12_132432_add_database_selection_to_backups', 1);
INSERT INTO public.migrations VALUES (91, '2023_10_18_072519_add_custom_labels_applications_table', 1);
INSERT INTO public.migrations VALUES (92, '2023_10_19_101331_create_standalone_mongodbs_table', 1);
INSERT INTO public.migrations VALUES (93, '2023_10_19_101332_add_standalone_mongodb_to_environment_variables_table', 1);
INSERT INTO public.migrations VALUES (94, '2023_10_24_103548_create_standalone_mysqls_table', 1);
INSERT INTO public.migrations VALUES (95, '2023_10_24_120523_create_standalone_mariadbs_table', 1);
INSERT INTO public.migrations VALUES (96, '2023_10_24_120524_add_standalone_mysql_to_environment_variables_table', 1);
INSERT INTO public.migrations VALUES (97, '2023_10_24_124934_add_is_shown_once_to_environment_variables_table', 1);
INSERT INTO public.migrations VALUES (98, '2023_11_01_100437_add_restart_to_deployment_queue', 1);
INSERT INTO public.migrations VALUES (99, '2023_11_07_123731_add_target_build_dockerfile', 1);
INSERT INTO public.migrations VALUES (100, '2023_11_08_112815_add_custom_config_standalone_postgresql', 1);
INSERT INTO public.migrations VALUES (101, '2023_11_09_133332_add_public_port_to_service_databases', 1);
INSERT INTO public.migrations VALUES (102, '2023_11_12_180605_change_fqdn_to_longer_field', 1);
INSERT INTO public.migrations VALUES (103, '2023_11_13_133059_add_sponsorship_disable', 1);
INSERT INTO public.migrations VALUES (104, '2023_11_14_103450_add_manual_webhook_secret', 1);
INSERT INTO public.migrations VALUES (105, '2023_11_14_121416_add_git_type', 1);
INSERT INTO public.migrations VALUES (106, '2023_11_16_101819_add_high_disk_usage_notification', 1);
INSERT INTO public.migrations VALUES (107, '2023_11_16_220647_add_log_drains', 1);
INSERT INTO public.migrations VALUES (108, '2023_11_17_160437_add_drain_log_enable_by_service', 1);
INSERT INTO public.migrations VALUES (109, '2023_11_20_094628_add_gpu_settings', 1);
INSERT INTO public.migrations VALUES (110, '2023_11_21_121920_add_additional_destinations_to_apps', 1);
INSERT INTO public.migrations VALUES (111, '2023_11_24_080341_add_docker_compose_location', 1);
INSERT INTO public.migrations VALUES (112, '2023_11_28_143533_add_fields_to_swarm_dockers', 1);
INSERT INTO public.migrations VALUES (113, '2023_11_29_075937_change_swarm_properties', 1);
INSERT INTO public.migrations VALUES (114, '2023_12_01_091723_save_logs_view_settings', 1);
INSERT INTO public.migrations VALUES (115, '2023_12_01_095356_add_custom_fluentd_config_for_logdrains', 1);
INSERT INTO public.migrations VALUES (116, '2023_12_08_162228_add_soft_delete_services', 1);
INSERT INTO public.migrations VALUES (117, '2023_12_11_103611_add_realtime_connection_problem', 1);
INSERT INTO public.migrations VALUES (118, '2023_12_13_110214_add_soft_deletes', 1);
INSERT INTO public.migrations VALUES (119, '2023_12_17_155616_add_custom_docker_compose_start_command', 1);
INSERT INTO public.migrations VALUES (120, '2023_12_18_093514_add_swarm_related_things', 1);
INSERT INTO public.migrations VALUES (121, '2023_12_19_124111_add_swarm_cluster_grouping', 1);
INSERT INTO public.migrations VALUES (122, '2023_12_30_134507_add_description_to_environments', 1);
INSERT INTO public.migrations VALUES (123, '2023_12_31_173041_create_scheduled_tasks_table', 1);
INSERT INTO public.migrations VALUES (124, '2024_01_01_231053_create_scheduled_task_executions_table', 1);
INSERT INTO public.migrations VALUES (125, '2024_01_02_113855_add_raw_compose_deployment', 1);
INSERT INTO public.migrations VALUES (126, '2024_01_12_123422_update_cpuset_limits', 1);
INSERT INTO public.migrations VALUES (127, '2024_01_15_084609_add_custom_dns_server', 1);
INSERT INTO public.migrations VALUES (128, '2024_01_16_115005_add_build_server_enable', 1);
INSERT INTO public.migrations VALUES (129, '2024_01_21_130328_add_docker_network_to_services', 1);
INSERT INTO public.migrations VALUES (130, '2024_01_23_095832_add_manual_webhook_secret_bitbucket', 1);
INSERT INTO public.migrations VALUES (131, '2024_01_23_113129_create_shared_environment_variables_table', 1);
INSERT INTO public.migrations VALUES (132, '2024_01_24_095449_add_concurrent_number_of_builds_per_server', 1);
INSERT INTO public.migrations VALUES (133, '2024_01_25_073212_add_server_id_to_queues', 1);
INSERT INTO public.migrations VALUES (134, '2024_01_27_164724_add_application_name_and_deployment_url_to_queue', 1);
INSERT INTO public.migrations VALUES (135, '2024_01_29_072322_change_env_variable_length', 1);
INSERT INTO public.migrations VALUES (136, '2024_01_29_145200_add_custom_docker_run_options', 1);
INSERT INTO public.migrations VALUES (137, '2024_02_01_111228_create_tags_table', 1);
INSERT INTO public.migrations VALUES (138, '2024_02_05_105215_add_destination_to_app_deployments', 1);
INSERT INTO public.migrations VALUES (139, '2024_02_06_132748_add_additional_destinations', 1);
INSERT INTO public.migrations VALUES (140, '2024_02_08_075523_add_post_deployment_to_applications', 1);
INSERT INTO public.migrations VALUES (141, '2024_02_08_112304_add_dynamic_timeout_for_deployments', 1);
INSERT INTO public.migrations VALUES (142, '2024_02_15_101921_add_consistent_application_container_name', 1);
INSERT INTO public.migrations VALUES (143, '2024_02_15_192025_add_is_gzip_enabled_to_services', 1);
INSERT INTO public.migrations VALUES (144, '2024_02_20_165045_add_permissions_to_github_app', 1);
INSERT INTO public.migrations VALUES (145, '2024_02_22_090900_add_only_this_server_deployment', 1);
INSERT INTO public.migrations VALUES (146, '2024_02_23_143119_add_custom_server_limits_to_teams_ultimate', 1);
INSERT INTO public.migrations VALUES (147, '2024_02_25_222150_add_server_force_disabled_field', 1);
INSERT INTO public.migrations VALUES (148, '2024_03_04_092244_add_gzip_enabled_and_stripprefix_settings', 1);
INSERT INTO public.migrations VALUES (149, '2024_03_07_115054_add_notifications_notification_disable', 1);
INSERT INTO public.migrations VALUES (150, '2024_03_08_180457_nullable_password', 1);
INSERT INTO public.migrations VALUES (151, '2024_03_11_150013_create_oauth_settings', 1);
INSERT INTO public.migrations VALUES (152, '2024_03_14_214402_add_multiline_envs', 1);
INSERT INTO public.migrations VALUES (153, '2024_03_18_101440_add_version_of_envs', 1);
INSERT INTO public.migrations VALUES (154, '2024_03_22_080914_remove_popup_notifications', 1);
INSERT INTO public.migrations VALUES (155, '2024_03_26_122110_remove_realtime_notifications', 1);
INSERT INTO public.migrations VALUES (156, '2024_03_28_114620_add_watch_paths_to_apps', 1);
INSERT INTO public.migrations VALUES (157, '2024_04_09_095517_make_custom_docker_commands_longer', 1);
INSERT INTO public.migrations VALUES (158, '2024_04_10_071920_create_standalone_keydbs_table', 1);
INSERT INTO public.migrations VALUES (159, '2024_04_10_082220_create_standalone_dragonflies_table', 1);
INSERT INTO public.migrations VALUES (160, '2024_04_10_091519_create_standalone_clickhouses_table', 1);
INSERT INTO public.migrations VALUES (161, '2024_04_10_124015_add_permission_local_file_volumes', 1);
INSERT INTO public.migrations VALUES (162, '2024_04_12_092337_add_config_hash_to_other_resources', 1);
INSERT INTO public.migrations VALUES (163, '2024_04_15_094703_add_literal_variables', 1);
INSERT INTO public.migrations VALUES (164, '2024_04_16_083919_add_service_type_on_creation', 1);
INSERT INTO public.migrations VALUES (165, '2024_04_17_132541_add_rollback_queues', 1);
INSERT INTO public.migrations VALUES (166, '2024_04_25_073615_add_docker_network_to_application_settings', 1);
INSERT INTO public.migrations VALUES (167, '2024_04_29_111956_add_custom_hc_indicator_apps', 1);
INSERT INTO public.migrations VALUES (168, '2024_05_06_093236_add_custom_name_to_application_settings', 1);
INSERT INTO public.migrations VALUES (169, '2024_05_07_124019_add_server_metrics', 1);
INSERT INTO public.migrations VALUES (170, '2024_05_10_085215_make_stripe_comment_longer', 1);
INSERT INTO public.migrations VALUES (171, '2024_05_15_091757_add_commit_message_to_app_deployment_queue', 1);
INSERT INTO public.migrations VALUES (172, '2024_05_15_151236_add_container_escape_toggle', 1);
INSERT INTO public.migrations VALUES (173, '2024_05_17_082012_add_env_sorting_toggle', 1);
INSERT INTO public.migrations VALUES (174, '2024_05_21_125739_add_scheduled_tasks_notification_to_teams', 1);
INSERT INTO public.migrations VALUES (175, '2024_05_22_103942_change_pre_post_deployment_commands_length_in_applications', 1);
INSERT INTO public.migrations VALUES (176, '2024_05_23_091713_add_gitea_webhook_to_applications', 1);
INSERT INTO public.migrations VALUES (177, '2024_06_05_101019_add_docker_compose_pr_domains', 1);
INSERT INTO public.migrations VALUES (178, '2024_06_06_103938_change_pr_issue_commend_id_type', 1);
INSERT INTO public.migrations VALUES (179, '2024_06_11_081614_add_www_non_www_redirect', 1);
INSERT INTO public.migrations VALUES (180, '2024_06_18_105948_move_server_metrics', 1);
INSERT INTO public.migrations VALUES (181, '2024_06_20_102551_add_server_api_sentinel', 1);
INSERT INTO public.migrations VALUES (182, '2024_06_21_143358_add_api_deployment_type', 1);
INSERT INTO public.migrations VALUES (183, '2024_06_22_081140_alter_instance_settings_add_instance_name', 1);
INSERT INTO public.migrations VALUES (184, '2024_06_25_184323_update_db', 1);
INSERT INTO public.migrations VALUES (185, '2024_07_01_115528_add_is_api_allowed_and_iplist', 1);
INSERT INTO public.migrations VALUES (186, '2024_07_05_120217_remove_unique_from_tag_names', 1);
INSERT INTO public.migrations VALUES (187, '2024_07_11_083719_application_compose_versions', 1);
INSERT INTO public.migrations VALUES (188, '2024_07_17_123828_add_is_container_labels_readonly', 1);
INSERT INTO public.migrations VALUES (189, '2024_07_18_110424_create_application_settings_is_preserve_repository_enabled', 1);
INSERT INTO public.migrations VALUES (190, '2024_07_18_123458_add_force_cleanup_server', 1);
INSERT INTO public.migrations VALUES (191, '2024_07_19_132617_disable_healtcheck_by_default', 1);
INSERT INTO public.migrations VALUES (192, '2024_07_23_112710_add_validation_logs_to_servers', 1);
INSERT INTO public.migrations VALUES (193, '2024_08_05_142659_add_update_frequency_settings', 1);
INSERT INTO public.migrations VALUES (194, '2024_08_07_155324_add_proxy_label_chooser', 1);
INSERT INTO public.migrations VALUES (195, '2024_08_09_215659_add_server_cleanup_fields_to_server_settings_table', 1);
INSERT INTO public.migrations VALUES (196, '2024_08_12_131659_add_local_file_volume_based_on_git', 1);
INSERT INTO public.migrations VALUES (197, '2024_08_12_155023_add_timezone_to_server_and_instance_settings', 1);
INSERT INTO public.migrations VALUES (198, '2024_08_14_183120_add_order_to_environment_variables_table', 1);
INSERT INTO public.migrations VALUES (199, '2024_08_15_115907_add_build_server_id_to_deployment_queue', 1);
INSERT INTO public.migrations VALUES (200, '2024_08_16_105649_add_custom_docker_options_to_dbs', 1);
INSERT INTO public.migrations VALUES (201, '2024_08_27_090528_add_compose_parsing_version_to_services', 1);
INSERT INTO public.migrations VALUES (202, '2024_09_05_085700_add_helper_version_to_instance_settings', 1);
INSERT INTO public.migrations VALUES (203, '2024_09_06_062534_change_server_cleanup_to_forced', 1);
INSERT INTO public.migrations VALUES (204, '2024_09_07_185402_change_cleanup_schedule', 1);
INSERT INTO public.migrations VALUES (205, '2024_09_08_130756_update_server_settings_default_timezone', 1);
INSERT INTO public.migrations VALUES (206, '2024_09_16_111428_encrypt_existing_private_keys', 1);
INSERT INTO public.migrations VALUES (207, '2024_09_17_111226_add_ssh_key_fingerprint_to_private_keys_table', 1);
INSERT INTO public.migrations VALUES (208, '2024_09_22_165240_add_advanced_options_to_cleanup_options_to_servers_settings_table', 1);
INSERT INTO public.migrations VALUES (209, '2024_09_26_083441_disable_api_by_default', 1);
INSERT INTO public.migrations VALUES (210, '2024_10_03_095427_add_dump_all_to_standalone_postgresqls', 1);
INSERT INTO public.migrations VALUES (211, '2024_10_10_081444_remove_constraint_from_service_applications_fqdn', 1);
INSERT INTO public.migrations VALUES (212, '2024_10_11_114331_add_required_env_variables', 1);
INSERT INTO public.migrations VALUES (213, '2024_10_14_090416_update_metrics_token_in_server_settings', 1);
INSERT INTO public.migrations VALUES (214, '2024_10_15_172139_add_is_shared_to_environment_variables', 1);
INSERT INTO public.migrations VALUES (215, '2024_10_16_120026_move_redis_password_to_envs', 1);
INSERT INTO public.migrations VALUES (216, '2024_10_16_192133_add_confirmation_settings_to_instance_settings_table', 1);
INSERT INTO public.migrations VALUES (217, '2024_10_17_093722_add_soft_delete_to_servers', 1);
INSERT INTO public.migrations VALUES (218, '2024_10_22_105745_add_server_disk_usage_threshold', 1);
INSERT INTO public.migrations VALUES (219, '2024_10_22_121223_add_server_disk_usage_notification', 1);
INSERT INTO public.migrations VALUES (220, '2024_10_29_093927_add_is_sentinel_debug_enabled_to_server_settings', 1);
INSERT INTO public.migrations VALUES (221, '2024_11_02_213214_add_last_online_at_to_resources', 1);
INSERT INTO public.migrations VALUES (222, '2024_11_11_125335_add_custom_nginx_configuration_to_static', 1);
INSERT INTO public.migrations VALUES (223, '2024_11_11_125366_add_index_to_activity_log', 2);
INSERT INTO public.migrations VALUES (224, '2024_10_30_074601_rename_token_permissions', 3);
INSERT INTO public.migrations VALUES (225, '2024_12_05_091823_add_disable_build_cache_advanced_option', 3);
INSERT INTO public.migrations VALUES (226, '2024_12_05_212355_create_email_notification_settings_table', 3);
INSERT INTO public.migrations VALUES (227, '2024_12_05_212416_create_discord_notification_settings_table', 3);
INSERT INTO public.migrations VALUES (228, '2024_12_05_212440_create_telegram_notification_settings_table', 3);
INSERT INTO public.migrations VALUES (229, '2024_12_05_212546_migrate_email_notification_settings_from_teams_table', 3);
INSERT INTO public.migrations VALUES (230, '2024_12_05_212631_migrate_discord_notification_settings_from_teams_table', 3);
INSERT INTO public.migrations VALUES (231, '2024_12_05_212705_migrate_telegram_notification_settings_from_teams_table', 3);
INSERT INTO public.migrations VALUES (232, '2024_12_06_142014_create_slack_notification_settings_table', 3);
INSERT INTO public.migrations VALUES (233, '2024_12_09_105711_drop_waitlists_table', 3);
INSERT INTO public.migrations VALUES (234, '2024_12_10_122142_encrypt_instance_settings_email_columns', 3);
INSERT INTO public.migrations VALUES (235, '2024_12_10_122143_drop_resale_license', 3);
INSERT INTO public.migrations VALUES (236, '2024_12_11_135026_create_pushover_notification_settings_table', 3);
INSERT INTO public.migrations VALUES (237, '2024_12_11_161418_add_authentik_base_url_to_oauth_settings_table', 3);
INSERT INTO public.migrations VALUES (238, '2024_12_13_103007_encrypt_resend_api_key_in_instance_settings', 3);
INSERT INTO public.migrations VALUES (239, '2024_12_23_142402_update_email_encryption_values', 4);
INSERT INTO public.migrations VALUES (240, '2024_11_22_124742_add_uuid_to_environments_table', 5);
INSERT INTO public.migrations VALUES (241, '2024_12_16_134437_add_resourceable_columns_to_environment_variables_table', 5);
INSERT INTO public.migrations VALUES (242, '2024_12_17_140637_add_server_disk_usage_check_frequency_to_server_settings_table', 5);
INSERT INTO public.migrations VALUES (243, '2025_01_08_154008_switch_up_readonly_labels', 5);
INSERT INTO public.migrations VALUES (244, '2025_01_10_135244_add_horizon_job_details_to_queue', 5);
INSERT INTO public.migrations VALUES (245, '2025_01_13_130238_add_backup_retention_fields_to_scheduled_database_backups_table', 5);
INSERT INTO public.migrations VALUES (246, '2025_01_15_130416_create_docker_cleanup_executions_table', 5);
INSERT INTO public.migrations VALUES (247, '2025_01_16_110406_change_commit_message_to_text_in_application_deployment_queues', 5);
INSERT INTO public.migrations VALUES (248, '2025_01_16_130238_add_finished_at_to_executions_tables', 5);
INSERT INTO public.migrations VALUES (249, '2025_01_21_125205_update_finished_at_timestamps_if_not_set', 5);
INSERT INTO public.migrations VALUES (250, '2025_01_22_101105_remove_wrongly_created_envs', 5);
INSERT INTO public.migrations VALUES (251, '2025_02_27_125249_add_index_to_scheduled_task_executions', 6);
INSERT INTO public.migrations VALUES (252, '2025_01_27_102616_add_ssl_fields_to_database_tables', 7);
INSERT INTO public.migrations VALUES (253, '2025_01_27_153741_create_ssl_certificates_table', 7);
INSERT INTO public.migrations VALUES (254, '2025_01_30_125223_encrypt_local_file_volumes_fields', 7);
INSERT INTO public.migrations VALUES (255, '2025_03_01_112617_add_stripe_past_due', 7);
INSERT INTO public.migrations VALUES (256, '2025_03_14_140150_add_storage_deletion_tracking_to_backup_executions', 7);
INSERT INTO public.migrations VALUES (257, '2025_03_21_104103_disable_discord_here', 7);
INSERT INTO public.migrations VALUES (258, '2025_03_26_104103_disable_mongodb_ssl_by_default', 8);
INSERT INTO public.migrations VALUES (259, '2025_03_29_204400_revert_some_local_volume_encryption', 9);
INSERT INTO public.migrations VALUES (260, '2025_03_31_124212_add_specific_spa_configuration', 9);
INSERT INTO public.migrations VALUES (261, '2025_01_05_050736_add_network_aliases_to_applications_table', 10);
INSERT INTO public.migrations VALUES (262, '2025_04_01_124212_stripe_comment_nullable', 11);
INSERT INTO public.migrations VALUES (263, '2025_04_17_110026_add_application_http_basic_auth_fields', 12);
INSERT INTO public.migrations VALUES (264, '2025_04_30_134146_add_is_migrated_to_services', 13);
INSERT INTO public.migrations VALUES (265, '2025_05_26_100258_add_server_patch_notifications', 14);
INSERT INTO public.migrations VALUES (266, '2025_05_29_100258_add_terminal_enabled_to_server_settings', 14);
INSERT INTO public.migrations VALUES (267, '2025_06_06_073345_create_server_previous_ip', 14);
INSERT INTO public.migrations VALUES (268, '2025_06_16_123532_change_sentinel_on_by_default', 14);
INSERT INTO public.migrations VALUES (269, '2025_06_25_131350_add_is_sponsorship_popup_enabled_to_instance_settings_table', 15);
INSERT INTO public.migrations VALUES (270, '2025_06_26_131350_optimize_activity_log_indexes', 16);
INSERT INTO public.migrations VALUES (271, '2025_07_14_191016_add_deleted_at_to_application_previews_table', 17);
INSERT INTO public.migrations VALUES (272, '2025_07_16_202201_add_timeout_to_scheduled_database_backups_table', 17);
INSERT INTO public.migrations VALUES (273, '2025_08_07_142403_create_user_changelog_reads_table', 17);
INSERT INTO public.migrations VALUES (274, '2025_08_17_102422_add_disable_local_backup_to_scheduled_database_backups_table', 17);
INSERT INTO public.migrations VALUES (275, '2025_08_18_104146_add_email_change_fields_to_users_table', 17);
INSERT INTO public.migrations VALUES (276, '2025_08_18_154244_change_env_sorting_default_to_false', 17);
INSERT INTO public.migrations VALUES (277, '2025_08_21_080234_add_git_shallow_clone_to_application_settings_table', 17);
INSERT INTO public.migrations VALUES (278, '2025_09_05_142446_add_pr_deployments_public_enabled_to_application_settings', 18);
INSERT INTO public.migrations VALUES (279, '2025_09_10_172952_remove_is_readonly_from_local_persistent_volumes_table', 18);
INSERT INTO public.migrations VALUES (280, '2025_09_10_173300_drop_webhooks_table', 18);
INSERT INTO public.migrations VALUES (281, '2025_09_10_173402_drop_kubernetes_table', 18);
INSERT INTO public.migrations VALUES (282, '2025_09_11_143432_remove_is_build_time_from_environment_variables_table', 18);
INSERT INTO public.migrations VALUES (283, '2025_09_11_150344_add_is_buildtime_only_to_environment_variables_table', 18);
INSERT INTO public.migrations VALUES (284, '2025_09_17_081112_add_use_build_secrets_to_application_settings', 19);
INSERT INTO public.migrations VALUES (285, '2025_09_18_080152_add_runtime_and_buildtime_to_environment_variables_table', 19);
INSERT INTO public.migrations VALUES (286, '2025_10_03_154100_update_clickhouse_image', 20);
INSERT INTO public.migrations VALUES (287, '2025_10_07_120723_add_s3_uploaded_to_scheduled_database_backup_executions_table', 20);
INSERT INTO public.migrations VALUES (288, '2025_10_08_181125_create_cloud_provider_tokens_table', 20);
INSERT INTO public.migrations VALUES (289, '2025_10_08_185203_add_hetzner_server_id_to_servers_table', 20);
INSERT INTO public.migrations VALUES (290, '2025_10_09_095905_add_cloud_provider_token_id_to_servers_table', 20);
INSERT INTO public.migrations VALUES (291, '2025_10_09_113602_add_hetzner_server_status_to_servers_table', 20);
INSERT INTO public.migrations VALUES (292, '2025_10_09_125036_add_is_validating_to_servers_table', 20);
INSERT INTO public.migrations VALUES (293, '2025_10_10_120000_create_cloud_init_scripts_table', 20);
INSERT INTO public.migrations VALUES (294, '2025_10_10_120000_create_webhook_notification_settings_table', 20);
INSERT INTO public.migrations VALUES (295, '2025_10_10_120001_populate_webhook_notification_settings_for_existing_teams', 20);
INSERT INTO public.migrations VALUES (296, '2025_11_02_161923_add_dev_helper_version_to_instance_settings', 20);
INSERT INTO public.migrations VALUES (297, '2025_11_09_000001_add_timeout_to_scheduled_tasks_table', 21);
INSERT INTO public.migrations VALUES (298, '2025_11_09_000002_improve_scheduled_task_executions_tracking', 21);
INSERT INTO public.migrations VALUES (299, '2025_11_10_112500_add_restart_tracking_to_applications_table', 21);
INSERT INTO public.migrations VALUES (300, '2025_11_12_130931_add_traefik_version_tracking_to_servers_table', 22);
INSERT INTO public.migrations VALUES (301, '2025_11_12_131252_add_traefik_outdated_to_email_notification_settings', 22);
INSERT INTO public.migrations VALUES (302, '2025_11_12_133400_add_traefik_outdated_thread_id_to_telegram_notification_settings', 22);
INSERT INTO public.migrations VALUES (303, '2025_11_14_114632_add_traefik_outdated_info_to_servers_table', 22);
INSERT INTO public.migrations VALUES (304, '2025_11_16_000001_create_webhook_notification_settings_table', 22);
INSERT INTO public.migrations VALUES (305, '2025_11_16_000002_create_cloud_init_scripts_table', 22);
INSERT INTO public.migrations VALUES (306, '2025_11_17_092707_add_traefik_outdated_to_notification_settings', 22);
INSERT INTO public.migrations VALUES (307, '2025_11_18_083747_cleanup_dockerfile_data_for_non_dockerfile_buildpacks', 22);
INSERT INTO public.migrations VALUES (308, '2025_11_26_124200_add_build_cache_settings_to_application_settings', 22);
INSERT INTO public.migrations VALUES (309, '2025_12_04_134435_add_deployment_queue_limit_to_server_settings', 23);
INSERT INTO public.migrations VALUES (310, '2025_12_05_000000_add_docker_images_to_keep_to_application_settings', 23);
INSERT INTO public.migrations VALUES (311, '2025_12_05_100000_add_disable_application_image_retention_to_server_settings', 23);
INSERT INTO public.migrations VALUES (312, '2025_12_08_135600_add_performance_indexes', 23);
INSERT INTO public.migrations VALUES (313, '2025_12_10_135600_add_uuid_to_cloud_provider_tokens', 23);
INSERT INTO public.migrations VALUES (314, '2025_12_15_143052_trim_s3_storage_credentials', 24);
INSERT INTO public.migrations VALUES (315, '2025_11_28_000001_migrate_clickhouse_to_official_image', 25);
INSERT INTO public.migrations VALUES (316, '2025_12_17_000001_add_is_wire_navigate_enabled_to_instance_settings_table', 25);
INSERT INTO public.migrations VALUES (317, '2025_12_17_000002_add_restart_tracking_to_standalone_databases', 25);
INSERT INTO public.migrations VALUES (318, '2025_11_17_145255_add_comment_to_environment_variables_table', 26);
INSERT INTO public.migrations VALUES (319, '2025_12_25_072315_add_cmd_healthcheck_to_applications_table', 26);
INSERT INTO public.migrations VALUES (320, '2026_02_26_163035_add_stripe_refunded_at_to_subscriptions_table', 26);
INSERT INTO public.migrations VALUES (321, '2026_02_27_000000_add_public_port_timeout_to_databases', 27);
INSERT INTO public.migrations VALUES (322, '2026_03_11_000000_add_server_metadata_to_servers_table', 27);
INSERT INTO public.migrations VALUES (323, '2026_03_16_000000_add_is_preview_suffix_enabled_to_volume_tables', 28);
INSERT INTO public.migrations VALUES (324, '2026_03_23_101720_add_uuid_to_local_persistent_volumes_table', 28);
INSERT INTO public.migrations VALUES (325, '2025_12_24_095507_add_server_to_shared_environment_variables_table', 29);
INSERT INTO public.migrations VALUES (326, '2025_12_24_133707_add_predefined_server_variables_to_existing_servers', 29);
INSERT INTO public.migrations VALUES (327, '2026_03_29_000000_encrypt_existing_clickhouse_admin_passwords', 29);
INSERT INTO public.migrations VALUES (328, '2026_03_30_120000_add_docker_registry_image_tag_to_application_previews_and_deployment_queues', 29);
INSERT INTO public.migrations VALUES (329, '2025_11_05_091558_add_stop_grace_period_to_application_settings', 30);
INSERT INTO public.migrations VALUES (330, '2026_04_19_000000_backfill_and_encrypt_webhook_secrets', 30);
INSERT INTO public.migrations VALUES (331, '2026_04_22_183029_add_is_mcp_server_enabled_to_instance_settings_table', 30);
INSERT INTO public.migrations VALUES (332, '2026_04_28_151408_add_connection_timeout_to_server_settings', 30);
INSERT INTO public.migrations VALUES (333, '2026_05_11_000000_add_configuration_snapshot_to_application_deployment_queues_table', 30);
INSERT INTO public.migrations VALUES (334, '2026_05_13_000000_add_expiration_warning_sent_at_to_personal_access_tokens_table', 30);
INSERT INTO public.migrations VALUES (335, '2026_03_26_000000_make_ports_exposes_nullable_in_applications_table', 31);
INSERT INTO public.migrations VALUES (336, '2026_03_27_000000_add_max_restart_count_to_applications', 31);
INSERT INTO public.migrations VALUES (337, '2026_05_27_000000_add_push_server_update_job_indexes', 31);
INSERT INTO public.migrations VALUES (338, '2026_05_27_000001_tune_postgres_fillfactor_and_autovacuum', 31);
INSERT INTO public.migrations VALUES (339, '2026_05_29_000000_encrypt_application_deployment_configuration_columns', 31);
INSERT INTO public.migrations VALUES (340, '2026_05_31_000000_add_health_check_to_standalone_databases', 31);
INSERT INTO public.migrations VALUES (341, '2026_03_17_073223_add_docker_registry_url_to_instance_settings', 32);
INSERT INTO public.migrations VALUES (342, '2026_06_01_210459_add_vultr_instance_fields_to_servers_table', 32);
INSERT INTO public.migrations VALUES (343, '2026_06_03_000000_add_oauth_fields_to_gitlab_apps_table', 32);
INSERT INTO public.migrations VALUES (344, '2026_06_25_000000_add_is_mcp_server_enabled_to_teams_table', 32);
INSERT INTO public.migrations VALUES (345, '2026_07_02_112425_add_is_host_file_to_local_file_volumes_table', 32);
INSERT INTO public.migrations VALUES (346, '2026_07_02_142003_add_webhook_internal_allowlist_to_instance_settings_table', 32);
INSERT INTO public.migrations VALUES (347, '2026_07_07_113248_add_team_name_unique_index_to_tags_table', 32);
INSERT INTO public.migrations VALUES (348, '2026_07_07_114840_add_digitalocean_droplet_fields_to_servers_table', 32);
INSERT INTO public.migrations VALUES (349, '2026_07_08_102340_add_description_to_cloud_provider_tokens_table', 32);
INSERT INTO public.migrations VALUES (350, '2026_07_08_105014_add_uuid_to_cloud_init_scripts_table', 32);
INSERT INTO public.migrations VALUES (351, '2026_07_12_090000_add_noindex_domains_to_applications_and_service_applications', 32);
INSERT INTO public.migrations VALUES (352, '2026_07_15_102537_create_scheduled_volume_backups_table', 32);
INSERT INTO public.migrations VALUES (353, '2026_07_15_102538_create_scheduled_volume_backup_executions_table', 32);
INSERT INTO public.migrations VALUES (354, '2026_07_24_091627_add_domain_dns_statuses_to_applications_table', 32);
INSERT INTO public.migrations VALUES (355, '2026_07_24_110621_add_domain_dns_statuses_to_service_applications_table', 32);
INSERT INTO public.migrations VALUES (356, '2026_07_29_100747_add_redirect_to_service_applications_table', 32);
INSERT INTO public.migrations VALUES (357, '2026_08_03_192434_add_domain_connect_private_key_to_instance_settings_table', 32);
INSERT INTO public.migrations VALUES (358, '2026_08_07_185535_add_avatar_columns_to_users_table', 32);
INSERT INTO public.migrations VALUES (359, '2026_08_07_185536_add_avatar_storage_settings_to_instance_settings_table', 32);
INSERT INTO public.migrations VALUES (360, '2026_08_13_085439_add_docker_version_to_server_settings_table', 33);
INSERT INTO public.migrations VALUES (361, '2026_08_13_140035_add_icon_columns_to_projects_table', 34);
INSERT INTO public.migrations VALUES (362, '2026_08_14_074053_add_backup_compression_cpu_percentage_to_server_settings_table', 34);
INSERT INTO public.migrations VALUES (363, '2026_08_15_000000_increase_default_volume_backup_timeout', 35);
INSERT INTO public.migrations VALUES (364, '2026_08_17_000000_add_is_force_https_enabled_to_service_applications_table', 35);
INSERT INTO public.migrations VALUES (365, '2026_08_18_104130_add_is_dashboard_force_https_enabled_to_instance_settings_table', 35);
INSERT INTO public.migrations VALUES (366, '2026_08_19_090916_add_smtp_ehlo_domain_to_email_settings', 36);
INSERT INTO public.migrations VALUES (367, '2026_08_20_070831_promote_first_team_member_when_team_has_no_owner', 36);
INSERT INTO public.migrations VALUES (368, '2026_08_28_193100_add_domain_dns_statuses_to_application_previews_table', 37);
INSERT INTO public.migrations VALUES (369, '2026_08_30_193506_add_container_present_to_applications_table', 37);
INSERT INTO public.migrations VALUES (370, '2026_08_30_220617_add_restart_limit_reached_to_applications_table', 37);
INSERT INTO public.migrations VALUES (371, '2026_08_31_073116_add_restart_limit_to_application_previews', 37);
INSERT INTO public.migrations VALUES (372, '2026_08_31_073117_add_restart_limit_to_service_applications', 37);
INSERT INTO public.migrations VALUES (373, '2026_08_31_073118_add_restart_limit_to_service_databases', 37);
INSERT INTO public.migrations VALUES (374, '2026_08_31_073119_add_restart_limit_to_standalone_postgresqls', 37);
INSERT INTO public.migrations VALUES (375, '2026_08_31_073120_add_restart_limit_to_standalone_redis', 37);
INSERT INTO public.migrations VALUES (376, '2026_08_31_073121_add_restart_limit_to_standalone_mongodbs', 37);
INSERT INTO public.migrations VALUES (377, '2026_08_31_073122_add_restart_limit_to_standalone_mysqls', 37);
INSERT INTO public.migrations VALUES (378, '2026_08_31_073123_add_restart_limit_to_standalone_mariadbs', 37);
INSERT INTO public.migrations VALUES (379, '2026_08_31_073124_add_restart_limit_to_standalone_keydbs', 37);
INSERT INTO public.migrations VALUES (380, '2026_08_31_073125_add_restart_limit_to_standalone_dragonflies', 37);
INSERT INTO public.migrations VALUES (381, '2026_08_31_073126_add_restart_limit_to_standalone_clickhouses', 37);
INSERT INTO public.migrations VALUES (382, '2026_08_31_092837_add_restart_limit_reached_notifications_to_email_notification_settings_table', 37);
INSERT INTO public.migrations VALUES (383, '2026_08_31_092838_add_restart_limit_reached_notifications_to_discord_notification_settings_table', 37);
INSERT INTO public.migrations VALUES (384, '2026_08_31_092840_add_restart_limit_reached_notifications_to_telegram_notification_settings_table', 37);
INSERT INTO public.migrations VALUES (385, '2026_08_31_092841_add_restart_limit_reached_notifications_to_slack_notification_settings_table', 37);
INSERT INTO public.migrations VALUES (386, '2026_08_31_092842_add_restart_limit_reached_notifications_to_pushover_notification_settings_table', 37);
INSERT INTO public.migrations VALUES (387, '2026_08_31_092843_add_restart_limit_reached_notifications_to_webhook_notification_settings_table', 37);
INSERT INTO public.migrations VALUES (388, '2026_09_01_210751_add_domain_port_overrides_to_service_applications_table', 37);
INSERT INTO public.migrations VALUES (389, '2026_09_02_064120_add_domain_port_overrides_to_applications_table', 37);
INSERT INTO public.migrations VALUES (390, '2026_09_02_132544_add_domain_port_overrides_to_application_previews_table', 37);
INSERT INTO public.migrations VALUES (391, '2026_09_04_132827_remove_restart_limits_from_databases', 38);
INSERT INTO public.migrations VALUES (392, '2026_08_20_150000_add_missing_backup_notification_fields_to_scheduled_database_backups_table', 39);
INSERT INTO public.migrations VALUES (393, '2026_09_04_191011_add_image_cdn_url_to_instance_settings_table', 39);
INSERT INTO public.migrations VALUES (394, '2026_08_24_131006_add_current_team_id_to_users_table', 40);
INSERT INTO public.migrations VALUES (395, '2026_09_08_202212_enable_sentinel_for_existing_regular_servers', 40);
INSERT INTO public.migrations VALUES (396, '2026_09_15_105627_make_restart_limits_opt_in', 41);
INSERT INTO public.migrations VALUES (397, '2026_09_16_102243_add_sentinel_waiting_since_to_servers_table', 42);
INSERT INTO public.migrations VALUES (398, '2026_09_18_111936_create_scheduled_job_states_and_deliveries_tables', 42);
INSERT INTO public.migrations VALUES (399, '2026_06_04_091631_add_oidc_fields_to_oauth_settings_table', 43);
INSERT INTO public.migrations VALUES (400, '2026_06_04_091631_create_oauth_identities_table', 43);
INSERT INTO public.migrations VALUES (401, '2026_06_04_091632_add_oauth_registration_policy_to_instance_settings_table', 43);
INSERT INTO public.migrations VALUES (402, '2026_06_23_151229_add_auto_join_root_team_to_oauth_settings_table', 43);
INSERT INTO public.migrations VALUES (403, '2026_08_10_191228_add_traffic_analytics_to_server_settings', 43);
INSERT INTO public.migrations VALUES (404, '2026_08_15_000000_create_integration_tokens_table', 43);
INSERT INTO public.migrations VALUES (405, '2026_08_20_000000_create_audit_events_table', 43);
INSERT INTO public.migrations VALUES (406, '2026_08_23_000000_add_secret_manager_integrations', 43);
INSERT INTO public.migrations VALUES (407, '2026_08_24_000000_create_dns_provider_zones_table', 43);
INSERT INTO public.migrations VALUES (408, '2026_08_24_000001_create_managed_dns_records_table', 43);
INSERT INTO public.migrations VALUES (409, '2026_08_24_171229_add_changes_to_audit_events_table', 43);
INSERT INTO public.migrations VALUES (410, '2026_09_08_214510_align_consistent_container_name_with_custom_internal_name', 43);
INSERT INTO public.migrations VALUES (411, '2026_09_08_214513_add_custom_container_name_prefix_to_application_settings_table', 43);
INSERT INTO public.migrations VALUES (412, '2026_09_18_145710_create_standalone_sqlites_table', 43);
INSERT INTO public.migrations VALUES (413, '2026_09_18_165916_add_is_build_server_fallback_enabled_to_teams_table', 43);
INSERT INTO public.migrations VALUES (414, '2026_09_19_121840_add_server_role_to_server_settings_table', 43);
INSERT INTO public.migrations VALUES (415, '2026_09_21_070754_remove_duplicate_additional_destinations', 43);
INSERT INTO public.migrations VALUES (416, '2026_09_21_070755_add_unique_index_to_additional_destinations_table', 43);
INSERT INTO public.migrations VALUES (417, '2026_09_21_100148_add_level_to_audit_events_table', 43);
INSERT INTO public.migrations VALUES (418, '2026_09_25_154121_add_owned_to_managed_dns_records_table', 43);
INSERT INTO public.migrations VALUES (419, '2026_09_25_154122_create_managed_dns_record_references_table', 43);
INSERT INTO public.migrations VALUES (420, '2026_09_25_210000_remove_legacy_traefik_dashboard_labels', 43);
INSERT INTO public.migrations VALUES (421, '2026_09_26_152908_add_standalone_sqlite_id_to_local_persistent_volumes_table', 43);
INSERT INTO public.migrations VALUES (422, '2026_09_28_100000_add_github_runner_fields_to_github_apps_table', 43);
INSERT INTO public.migrations VALUES (423, '2026_09_28_100001_create_github_runner_configs_table', 43);
INSERT INTO public.migrations VALUES (424, '2026_09_28_100002_create_github_runner_executions_table', 43);
INSERT INTO public.migrations VALUES (425, '2026_09_28_121242_add_parent_deployment_uuid_to_application_deployment_queues_table', 43);
INSERT INTO public.migrations VALUES (426, '2026_09_29_082403_add_disk_usage_notification_interval_to_server_settings_table', 43);
INSERT INTO public.migrations VALUES (427, '2026_09_29_083244_create_notification_throttles_table', 43);
INSERT INTO public.migrations VALUES (428, '2026_09_29_200325_add_created_before_oauth_identities_to_users_table', 43);
INSERT INTO public.migrations VALUES (429, '2026_09_30_115702_add_ignores_compose_driver_options_to_local_persistent_volumes_table', 43);
INSERT INTO public.migrations VALUES (430, '2026_09_30_120000_rekey_oauth_identity_issuers_to_provider_instance', 43);
INSERT INTO public.migrations VALUES (431, '2026_10_01_051935_add_allow_pull_requests_to_github_runner_configs_table', 43);
INSERT INTO public.migrations VALUES (432, '2026_10_02_055938_remove_next_run_at_from_scheduled_jobs', 43);
INSERT INTO public.migrations VALUES (433, '2026_10_02_120000_add_legacy_password_quoting_to_keydb_and_dragonfly', 43);
INSERT INTO public.migrations VALUES (434, '2026_10_03_172204_add_recovery_bounds_to_scheduled_volume_backup_executions_table', 43);
INSERT INTO public.migrations VALUES (435, '2026_10_05_064824_add_is_pull_request_to_github_runner_executions_table', 43);
INSERT INTO public.migrations VALUES (436, '2026_10_05_064841_close_legacy_enqueued_scheduled_job_deliveries', 43);
INSERT INTO public.migrations VALUES (437, '2026_10_05_204113_add_legacy_password_quoting_to_standalone_redis', 43);
INSERT INTO public.migrations VALUES (438, '2026_10_07_072758_add_missing_backup_notification_days_to_scheduled_volume_backups_table', 43);
INSERT INTO public.migrations VALUES (439, '2026_10_07_092441_add_traffic_ip_mode_to_server_settings', 43);
INSERT INTO public.migrations VALUES (440, '2026_10_09_092903_normalize_ipv6_server_ips', 44);
INSERT INTO public.migrations VALUES (441, '2026_10_09_115444_remove_duplicate_redis_username_environment_variables', 44);
INSERT INTO public.migrations VALUES (442, '2026_10_09_124641_remove_duplicate_nixpacks_node_version_environment_variables', 44);
INSERT INTO public.migrations VALUES (443, '2026_07_10_210239_add_hostinger_virtual_machine_fields_to_servers_table', 45);
INSERT INTO public.migrations VALUES (444, '2026_09_24_055934_add_cloudwatch_log_drain_to_server_settings_table', 45);
INSERT INTO public.migrations VALUES (445, '2026_09_25_105051_add_redact_all_env_values_in_logs_to_resources', 45);
INSERT INTO public.migrations VALUES (446, '2026_09_27_154836_add_uses_legacy_escaping_to_environment_variables_table', 45);
INSERT INTO public.migrations VALUES (447, '2026_10_01_132654_add_proxy_error_page_to_servers_table', 45);
INSERT INTO public.migrations VALUES (448, '2026_10_01_161644_add_maintenance_mode_to_applications_and_services_tables', 45);
INSERT INTO public.migrations VALUES (449, '2026_10_02_170101_add_http_basic_auth_hash_options_to_applications_table', 45);
INSERT INTO public.migrations VALUES (450, '2026_10_07_125311_add_cloudflare_tunnel_api_fields_to_server_settings', 45);
INSERT INTO public.migrations VALUES (451, '2026_10_07_150000_create_backup_s3_destination_tables', 45);
INSERT INTO public.migrations VALUES (452, '2026_10_11_075120_add_traefik_certificate_resolver_to_server_settings_table', 45);
INSERT INTO public.migrations VALUES (453, '2026_10_11_145529_add_traefik_certificate_resolver_to_application_and_service_settings', 45);
INSERT INTO public.migrations VALUES (454, '2026_10_11_183411_add_preserve_compose_null_to_environment_variables', 45);
INSERT INTO public.migrations VALUES (455, '2026_10_12_002632_add_is_backup_before_update_enabled_to_instance_settings_table', 45);
INSERT INTO public.migrations VALUES (456, '2026_10_12_100000_create_gitea_apps_table', 45);
INSERT INTO public.migrations VALUES (457, '2026_10_12_121520_add_failure_count_to_notification_settings_tables', 45);
INSERT INTO public.migrations VALUES (458, '2026_10_12_154805_add_application_id_index_to_application_settings_table', 45);
INSERT INTO public.migrations VALUES (459, '2026_10_12_164601_create_passkeys_table', 45);
INSERT INTO public.migrations VALUES (460, '2026_10_12_192444_add_canvas_positions_to_environments_table', 45);
INSERT INTO public.migrations VALUES (461, '2026_10_12_192445_create_resource_links_table', 45);
INSERT INTO public.migrations VALUES (462, '2026_10_13_101731_add_redact_all_env_values_in_logs_to_standalone_databases', 45);
INSERT INTO public.migrations VALUES (463, '2026_10_13_132049_add_avatar_columns_to_teams_table', 45);
INSERT INTO public.migrations VALUES (464, '2026_10_14_105230_add_file_download_storage_to_instance_settings_table', 45);
INSERT INTO public.migrations VALUES (465, '2026_10_15_213357_spread_default_auto_update_frequency', 45);
INSERT INTO public.migrations VALUES (466, '2026_10_18_103517_add_include_coolify_default_variables_to_resources', 45);
INSERT INTO public.migrations VALUES (467, '2026_10_18_120000_add_deployment_commit_details_to_email_notification_settings', 45);
INSERT INTO public.migrations VALUES (468, '2026_10_19_082209_add_patch_check_to_server_settings_table', 45);
INSERT INTO public.migrations VALUES (469, '2026_10_19_083521_encrypt_plaintext_secrets', 45);
INSERT INTO public.migrations VALUES (470, '2026_10_19_101103_add_ended_at_to_subscriptions_table', 45);
INSERT INTO public.migrations VALUES (471, '2026_10_19_120000_add_auto_security_updates_to_server_settings_table', 45);
INSERT INTO public.migrations VALUES (472, '2026_10_19_191912_add_is_permanent_redirect_enabled_to_redirect_settings', 45);
INSERT INTO public.migrations VALUES (473, '2026_10_23_090005_add_server_validation_limits_to_instance_settings_table', 45);
INSERT INTO public.migrations VALUES (474, '2026_10_23_182201_add_canvas_position_to_projects_table', 46);
INSERT INTO public.migrations VALUES (475, '2026_10_23_200902_add_canvas_position_to_servers_table', 46);
INSERT INTO public.migrations VALUES (476, '2026_10_23_224202_add_rolling_update_drain_seconds_to_application_settings', 46);
INSERT INTO public.migrations VALUES (477, '2026_10_25_115811_add_is_two_factor_required_to_teams_table', 46);
INSERT INTO public.migrations VALUES (478, '2026_10_27_142752_add_use_path_style_endpoint_to_s3_storages_table', 46);
INSERT INTO public.migrations VALUES (479, '2026_10_27_155023_add_logdrain_axiom_domain_to_server_settings_table', 46);
INSERT INTO public.migrations VALUES (480, '2026_10_27_160258_remove_highlight_log_drain_from_server_settings_table', 46);
INSERT INTO public.migrations VALUES (481, '2026_10_28_103619_add_keeps_production_values_to_application_previews_table', 46);
INSERT INTO public.migrations VALUES (482, '2026_10_28_124421_keep_dockerfile_healthcheck_for_existing_applications', 46);
INSERT INTO public.migrations VALUES (483, '2026_10_25_100000_add_access_grants_to_team_members_and_tokens', 47);
INSERT INTO public.migrations VALUES (484, '2026_10_26_081954_add_git_https_credentials_to_applications_table', 47);
INSERT INTO public.migrations VALUES (485, '2026_10_27_142736_add_paused_at_to_personal_access_tokens_table', 47);
INSERT INTO public.migrations VALUES (486, '2026_10_28_204953_add_worker_host_to_scheduled_job_executions', 47);
INSERT INTO public.migrations VALUES (487, '2026_10_28_211105_add_indexes_for_team_deployments_and_docker_cleanup_history', 47);
INSERT INTO public.migrations VALUES (488, '2026_10_28_212642_add_indexes_for_server_settings_and_team_membership_lookups', 47);
INSERT INTO public.migrations VALUES (489, '2026_10_28_214500_add_index_for_application_deployment_history', 47);
INSERT INTO public.migrations VALUES (490, '2026_10_28_214953_add_index_for_interrupted_docker_cleanup_executions', 47);
INSERT INTO public.migrations VALUES (491, '2026_10_28_224219_add_index_for_active_github_runner_executions', 47);
INSERT INTO public.migrations VALUES (492, '2026_10_28_224423_add_index_for_dashboard_recent_deployments', 47);
INSERT INTO public.migrations VALUES (493, '2026_10_28_232000_add_index_for_active_servers_by_private_key', 47);
INSERT INTO public.migrations VALUES (494, '2026_10_29_221743_add_checkout_reminder_sent_at_to_subscriptions_table', 47);
INSERT INTO public.migrations VALUES (495, '2026_10_30_144551_add_access_to_team_invitations_table', 47);
INSERT INTO public.migrations VALUES (496, '2026_10_30_171359_drop_image_default_from_standalone_sqlites_table', 47);
INSERT INTO public.migrations VALUES (497, '2026_11_01_142702_add_update_channel_to_instance_settings_table', 47);

SELECT pg_catalog.setval('public.migrations_id_seq', 497, true);

