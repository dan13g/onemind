# Example Power BI model

Connect Power BI to `ONEMIND_DIM_DW.CORE` and import:

- DIM_DATE
- DIM_CLIENT
- DIM_CLINICIAN
- DIM_SERVICE
- DIM_ORGANISATION
- FACT_REFERRAL
- FACT_ASSESSMENT
- FACT_SESSION
- FACT_OUTCOME
- FACT_RISK_ASSESSMENT
- FACT_GOAL

Recommended pages:

1. **Executive overview** – clients, referrals, completed sessions, DNA/cancellation rate, waiting time.
2. **Client journey** – referral -> assessment -> sessions -> outcomes for selected client.
3. **Clinician activity** – sessions per clinician, average duration, DNA/cancellations.
4. **Clinical outcomes** – GAD-7 / PHQ-9 score trends and outcome completion.
5. **Referral & waiting list** – referral volume, status, source, days to first session.

Power BI should use the dimensional layer, not Raw Vault tables directly.
