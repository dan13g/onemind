# DAX examples

```DAX
Total Clients = DISTINCTCOUNT(DIM_CLIENT[CLIENT_KEY])
Total Referrals = SUM(FACT_REFERRAL[REFERRAL_COUNT])
Total Sessions = COUNTROWS(FACT_SESSION)
Completed Sessions = SUM(FACT_SESSION[COMPLETED_SESSION_COUNT])
DNA Sessions = SUM(FACT_SESSION[DNA_SESSION_COUNT])
Cancelled Sessions = SUM(FACT_SESSION[CANCELLED_SESSION_COUNT])
DNA Rate = DIVIDE([DNA Sessions],[Total Sessions])
Cancellation Rate = DIVIDE([Cancelled Sessions],[Total Sessions])
Average Session Duration = AVERAGE(FACT_SESSION[DURATION_MINUTES])
Average Waiting Days = AVERAGE(FACT_REFERRAL[DAYS_TO_FIRST_SESSION])
Average Outcome Score = AVERAGE(FACT_OUTCOME[SCORE_VALUE])
```
