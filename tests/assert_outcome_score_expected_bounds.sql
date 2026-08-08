select * from {{ ref('fact_outcome') }} where score_value<0 or score_value>40
