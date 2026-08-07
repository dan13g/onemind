-- =========================================================
-- OneMind Healthcare + BrightPath Mental Health
-- Realistic Stage 1 Postgres source systems
--
-- Data volume deliberately kept to a few thousand rows.
-- Approximate inserted rows: 26,209 total, safely below the 500,000-row project ceiling.
--
-- Scenario:
-- OneMind Healthcare acquired BrightPath Mental Health.
-- Both systems live in one Postgres schema for this project.
-- Prefixes:
--   onemind_*     = acquiring company clinical platform
--   brightpath_*  = acquired EAP/corporate mental-health platform
-- =========================================================

DROP TABLE IF EXISTS
    onemind_outcome_scores,
    onemind_risk_assessments,
    onemind_care_plan_goals,
    onemind_sessions,
    onemind_waitlist_events,
    onemind_discharges,
    onemind_episodes,
    onemind_assessments,
    onemind_referrals,
    onemind_clients,
    onemind_clinicians,
    onemind_teams,
    onemind_locations,
    onemind_organisations,
    onemind_services,
    brightpath_outcome_scores,
    brightpath_risk_assessments,
    brightpath_care_plan_goals,
    brightpath_sessions,
    brightpath_episode_status_history,
    brightpath_episodes,
    brightpath_referrals,
    brightpath_clients,
    brightpath_clinicians,
    brightpath_organisations,
    brightpath_services,
    brightpath_acquisition_metadata
CASCADE;

CREATE TABLE onemind_services (
    service_id INTEGER PRIMARY KEY,
    service_code TEXT NOT NULL UNIQUE,
    service_name TEXT NOT NULL,
    modality TEXT NOT NULL,
    intensity_level TEXT NOT NULL,
    target_wait_days INTEGER,
    active_flag BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE onemind_organisations (
    organisation_id INTEGER PRIMARY KEY,
    organisation_type TEXT NOT NULL,
    organisation_code TEXT,
    organisation_name TEXT NOT NULL,
    postcode TEXT,
    region TEXT,
    active_flag BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE onemind_locations (
    location_id INTEGER PRIMARY KEY,
    location_code TEXT NOT NULL UNIQUE,
    location_name TEXT NOT NULL,
    location_type TEXT NOT NULL,
    town_city TEXT,
    postcode TEXT,
    region TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE onemind_teams (
    team_id INTEGER PRIMARY KEY,
    team_code TEXT NOT NULL UNIQUE,
    team_name TEXT NOT NULL,
    region TEXT,
    service_line TEXT,
    active_flag BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE onemind_clinicians (
    clinician_id INTEGER PRIMARY KEY,
    staff_number TEXT NOT NULL UNIQUE,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    professional_role TEXT NOT NULL,
    registration_body TEXT,
    registration_number TEXT,
    team_id INTEGER REFERENCES onemind_teams(team_id),
    base_location_id INTEGER REFERENCES onemind_locations(location_id),
    employment_type TEXT,
    start_date DATE,
    leaving_date DATE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE onemind_clients (
    client_id INTEGER PRIMARY KEY,
    nhs_number TEXT,
    local_client_ref TEXT NOT NULL UNIQUE,
    title TEXT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    date_of_birth DATE NOT NULL,
    gender TEXT,
    email_address TEXT,
    mobile_phone TEXT,
    address_line_1 TEXT,
    town_city TEXT,
    postcode TEXT,
    ethnicity TEXT,
    registered_gp_org_id INTEGER REFERENCES onemind_organisations(organisation_id),
    employer_org_id INTEGER REFERENCES onemind_organisations(organisation_id),
    consent_to_contact BOOLEAN NOT NULL DEFAULT TRUE,
    deceased_flag BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE onemind_referrals (
    referral_id INTEGER PRIMARY KEY,
    client_id INTEGER NOT NULL REFERENCES onemind_clients(client_id),
    referral_received_at TIMESTAMP NOT NULL,
    referral_source TEXT NOT NULL,
    referring_org_id INTEGER REFERENCES onemind_organisations(organisation_id),
    referred_by_name TEXT,
    presenting_problem TEXT,
    risk_level_at_referral TEXT NOT NULL,
    priority TEXT NOT NULL,
    referral_status TEXT NOT NULL,
    service_id INTEGER REFERENCES onemind_services(service_id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE onemind_assessments (
    assessment_id INTEGER PRIMARY KEY,
    referral_id INTEGER NOT NULL REFERENCES onemind_referrals(referral_id),
    assessor_clinician_id INTEGER REFERENCES onemind_clinicians(clinician_id),
    assessment_at TIMESTAMP NOT NULL,
    assessment_type TEXT NOT NULL,
    clinical_summary TEXT,
    recommended_service_id INTEGER REFERENCES onemind_services(service_id),
    accepted_for_treatment BOOLEAN,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE onemind_episodes (
    episode_id INTEGER PRIMARY KEY,
    referral_id INTEGER NOT NULL REFERENCES onemind_referrals(referral_id),
    episode_start_date DATE NOT NULL,
    episode_end_date DATE,
    primary_problem TEXT,
    provisional_diagnosis TEXT,
    care_pathway TEXT,
    discharge_reason TEXT,
    outcome_status TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE onemind_waitlist_events (
    waitlist_event_id INTEGER PRIMARY KEY,
    referral_id INTEGER NOT NULL REFERENCES onemind_referrals(referral_id),
    event_at TIMESTAMP NOT NULL,
    event_type TEXT NOT NULL,
    waitlist_category TEXT,
    reason TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE onemind_sessions (
    session_id INTEGER PRIMARY KEY,
    episode_id INTEGER NOT NULL REFERENCES onemind_episodes(episode_id),
    clinician_id INTEGER REFERENCES onemind_clinicians(clinician_id),
    location_id INTEGER REFERENCES onemind_locations(location_id),
    session_start_at TIMESTAMP NOT NULL,
    session_end_at TIMESTAMP NOT NULL,
    session_type TEXT NOT NULL,
    delivery_channel TEXT NOT NULL,
    attendance_status TEXT NOT NULL,
    cancellation_reason TEXT,
    clinical_notes_entered BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE onemind_care_plan_goals (
    care_plan_goal_id INTEGER PRIMARY KEY,
    episode_id INTEGER NOT NULL REFERENCES onemind_episodes(episode_id),
    goal_description TEXT NOT NULL,
    goal_status TEXT NOT NULL,
    target_date DATE,
    review_date DATE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE onemind_risk_assessments (
    risk_assessment_id INTEGER PRIMARY KEY,
    episode_id INTEGER NOT NULL REFERENCES onemind_episodes(episode_id),
    assessed_at TIMESTAMP NOT NULL,
    risk_domain TEXT NOT NULL,
    risk_level TEXT NOT NULL,
    safety_plan_required BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE onemind_outcome_scores (
    outcome_score_id INTEGER PRIMARY KEY,
    session_id INTEGER NOT NULL REFERENCES onemind_sessions(session_id),
    measure_name TEXT NOT NULL,
    score_value INTEGER NOT NULL,
    score_date DATE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE onemind_discharges (
    discharge_id INTEGER PRIMARY KEY,
    episode_id INTEGER NOT NULL REFERENCES onemind_episodes(episode_id),
    discharged_at TIMESTAMP NOT NULL,
    discharge_reason TEXT NOT NULL,
    onward_referral_flag BOOLEAN NOT NULL DEFAULT FALSE,
    onward_referral_to TEXT,
    discharge_notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE brightpath_acquisition_metadata (
    acquisition_id INTEGER PRIMARY KEY,
    acquired_company_name TEXT NOT NULL,
    legal_entity_name TEXT NOT NULL,
    acquisition_date DATE NOT NULL,
    source_system_name TEXT NOT NULL,
    source_system_owner TEXT,
    migration_wave TEXT,
    notes TEXT,
    created_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE brightpath_organisations (
    organisation_key INTEGER PRIMARY KEY,
    organisation_name TEXT NOT NULL,
    sector TEXT,
    contract_start_date DATE,
    contract_end_date DATE,
    account_manager TEXT,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE brightpath_services (
    service_key INTEGER PRIMARY KEY,
    service_code TEXT NOT NULL UNIQUE,
    service_name TEXT NOT NULL,
    care_type TEXT NOT NULL,
    max_sessions INTEGER,
    channel_default TEXT,
    created_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE brightpath_clinicians (
    clinician_key INTEGER PRIMARY KEY,
    clinician_ref TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    role_title TEXT NOT NULL,
    registration_body TEXT,
    registration_no TEXT,
    city TEXT,
    status TEXT NOT NULL,
    created_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE brightpath_clients (
    client_key INTEGER PRIMARY KEY,
    external_client_id TEXT NOT NULL UNIQUE,
    nhs_no_raw TEXT,
    given_name TEXT NOT NULL,
    family_name TEXT NOT NULL,
    dob DATE NOT NULL,
    sex TEXT,
    email TEXT,
    phone TEXT,
    postcode_raw TEXT,
    organisation_key INTEGER REFERENCES brightpath_organisations(organisation_key),
    employee_payroll_id TEXT,
    marketing_opt_in BOOLEAN,
    created_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE brightpath_referrals (
    intake_key INTEGER PRIMARY KEY,
    client_key INTEGER NOT NULL REFERENCES brightpath_clients(client_key),
    opened_ts TIMESTAMP NOT NULL,
    channel TEXT NOT NULL,
    referral_reason TEXT,
    initial_severity TEXT,
    urgent_flag BOOLEAN NOT NULL DEFAULT FALSE,
    current_state TEXT NOT NULL,
    service_key INTEGER REFERENCES brightpath_services(service_key),
    created_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE brightpath_episodes (
    episode_key INTEGER PRIMARY KEY,
    intake_key INTEGER NOT NULL REFERENCES brightpath_referrals(intake_key),
    episode_open_date DATE NOT NULL,
    episode_close_date DATE,
    main_condition_text TEXT,
    icd10_code TEXT,
    close_reason TEXT,
    clinical_outcome TEXT,
    created_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE brightpath_episode_status_history (
    episode_status_history_key INTEGER PRIMARY KEY,
    episode_key INTEGER NOT NULL REFERENCES brightpath_episodes(episode_key),
    status_ts TIMESTAMP NOT NULL,
    episode_state TEXT NOT NULL,
    reason TEXT,
    created_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE brightpath_sessions (
    session_key INTEGER PRIMARY KEY,
    episode_key INTEGER NOT NULL REFERENCES brightpath_episodes(episode_key),
    clinician_key INTEGER REFERENCES brightpath_clinicians(clinician_key),
    starts_at TIMESTAMP NOT NULL,
    duration_minutes INTEGER NOT NULL,
    session_type TEXT NOT NULL,
    contact_method TEXT NOT NULL,
    status_code TEXT NOT NULL,
    notes_entered_flag BOOLEAN NOT NULL DEFAULT FALSE,
    created_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE brightpath_care_plan_goals (
    care_plan_goal_key INTEGER PRIMARY KEY,
    episode_key INTEGER NOT NULL REFERENCES brightpath_episodes(episode_key),
    goal_description TEXT NOT NULL,
    progress_rating INTEGER,
    review_ts TIMESTAMP NOT NULL,
    created_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE brightpath_risk_assessments (
    risk_assessment_key INTEGER PRIMARY KEY,
    episode_key INTEGER NOT NULL REFERENCES brightpath_episodes(episode_key),
    flagged_ts TIMESTAMP NOT NULL,
    risk_domain TEXT NOT NULL,
    risk_level TEXT NOT NULL,
    escalation_required BOOLEAN NOT NULL DEFAULT FALSE,
    created_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE brightpath_outcome_scores (
    outcome_score_key INTEGER PRIMARY KEY,
    session_key INTEGER NOT NULL REFERENCES brightpath_sessions(session_key),
    measure_name TEXT NOT NULL,
    score_value INTEGER NOT NULL,
    score_date DATE NOT NULL,
    created_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- =========================================================
-- Operational integrity constraints
-- These keep the training data realistic without changing the agreed domains.
-- =========================================================
ALTER TABLE onemind_sessions
    ADD CONSTRAINT chk_onemind_session_times CHECK (session_end_at > session_start_at);
ALTER TABLE onemind_episodes
    ADD CONSTRAINT chk_onemind_episode_dates CHECK (episode_end_date IS NULL OR episode_end_date >= episode_start_date);
ALTER TABLE onemind_outcome_scores
    ADD CONSTRAINT chk_onemind_score_range CHECK (score_value BETWEEN 0 AND 40);
ALTER TABLE onemind_referrals
    ADD CONSTRAINT chk_onemind_referral_risk CHECK (risk_level_at_referral IN ('Low','Medium','High')),
    ADD CONSTRAINT chk_onemind_referral_priority CHECK (priority IN ('Routine','Urgent'));
ALTER TABLE onemind_sessions
    ADD CONSTRAINT chk_onemind_attendance_status CHECK (attendance_status IN ('Attended','DNA','Cancelled by client','Cancelled by service'));
ALTER TABLE brightpath_sessions
    ADD CONSTRAINT chk_brightpath_duration CHECK (duration_minutes > 0 AND duration_minutes <= 240),
    ADD CONSTRAINT chk_brightpath_session_status CHECK (status_code IN ('COMPLETE','NO_SHOW','CLIENT_CANCEL','PROVIDER_CANCEL'));
ALTER TABLE brightpath_episodes
    ADD CONSTRAINT chk_brightpath_episode_dates CHECK (episode_close_date IS NULL OR episode_close_date >= episode_open_date);
ALTER TABLE brightpath_outcome_scores
    ADD CONSTRAINT chk_brightpath_score_range CHECK (score_value BETWEEN 0 AND 40);
ALTER TABLE brightpath_risk_assessments
    ADD CONSTRAINT chk_brightpath_risk_level CHECK (risk_level IN ('GREEN','AMBER','RED'));

-- Foreign-key and incremental-extract indexes commonly required in operational systems.
CREATE INDEX idx_onemind_clients_updated_at ON onemind_clients(updated_at);
CREATE INDEX idx_onemind_referrals_client ON onemind_referrals(client_id);
CREATE INDEX idx_onemind_referrals_updated_at ON onemind_referrals(updated_at);
CREATE INDEX idx_onemind_assessments_referral ON onemind_assessments(referral_id);
CREATE INDEX idx_onemind_episodes_referral ON onemind_episodes(referral_id);
CREATE INDEX idx_onemind_sessions_episode ON onemind_sessions(episode_id);
CREATE INDEX idx_onemind_sessions_clinician ON onemind_sessions(clinician_id);
CREATE INDEX idx_onemind_sessions_updated_at ON onemind_sessions(updated_at);
CREATE INDEX idx_onemind_outcomes_session ON onemind_outcome_scores(session_id);
CREATE INDEX idx_brightpath_clients_modified_ts ON brightpath_clients(modified_ts);
CREATE INDEX idx_brightpath_referrals_client ON brightpath_referrals(client_key);
CREATE INDEX idx_brightpath_referrals_modified_ts ON brightpath_referrals(modified_ts);
CREATE INDEX idx_brightpath_episodes_referral ON brightpath_episodes(intake_key);
CREATE INDEX idx_brightpath_sessions_episode ON brightpath_sessions(episode_key);
CREATE INDEX idx_brightpath_sessions_clinician ON brightpath_sessions(clinician_key);
CREATE INDEX idx_brightpath_sessions_modified_ts ON brightpath_sessions(modified_ts);
CREATE INDEX idx_brightpath_outcomes_session ON brightpath_outcome_scores(session_key);
