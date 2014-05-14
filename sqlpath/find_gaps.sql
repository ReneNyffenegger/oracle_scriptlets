--
--     Find gaps.
--
--     This script finds "Value Gaps" in columns that contain
--     numeric, non fractional values (integers), possibly 
--     created by sequences.
--
select a+1        "From/Start Value", 
       lead_      "To (Value)",
       lead_ - a  "Size"
  from (
select &&column                                            a,
       lag (&&column) over (order by &&column) lag_,
       lead(&&column) over (order by &&column) lead_,
      &&column - lead(&&column) over (order by &&column) count_
  from &&table
 order by &&column - lead(&&column) over (order by &&column)
)
where rownum < 20;
