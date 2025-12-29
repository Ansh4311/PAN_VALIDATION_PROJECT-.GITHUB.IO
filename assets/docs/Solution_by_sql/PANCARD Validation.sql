-PAN Number Validation Project Using Sql

Create table stg_pan_numbers_dataset
(
    pan_number        text
)
select * from stg_pan_numbers_dataset

--Identify and Handle Missing Data:
select * from stg_pan_numbers_dataset where pan_number is null

--Check for duplicates: Ensure there are no duplicate PAN numbers. If duplicates exist, remove them.

select pan_number, count(1) 
from stg_pan_numbers_dataset 
group by pan_number
having count(1)> 1

--Handle leading/trailing spaces: PAN numbers may have extra spaces before or after the actual number.
Remove any such spaces.

select * 
from stg_pan_numbers_dataset
where pan_number <> trim(pan_number)

--Correct letter case: Ensure that the PAN numbers are in uppercase letters
(if any lowercase letters are present).

select * 
from stg_pan_numbers_dataset
where pan_number <> upper(pan_number)

--Cleaned Pan Number
select distinct upper(trim(pan_number)) as pan_number
from stg_pan_numbers_dataset
where pan_number is not null
and trim(pan_number) <> ''

--Function to check if adjacent characters are the same --ZNOV03987M==> ZWOVO
Create or replace function fn_check_adjacent_characters(p_str text)
returns boolean
language plpgsql
as $$
begin 
      for i in 1..(length(p_str)-1)
	  loop
	      if substring(p_str,i,1) = substring(p_str,i+1,1)
		  then 
		    return true;
		  end if;
	  end loop;
	  return false;
end;
$$

select fn_check_adjacent_characters('XXQWE3')

--Function to check if sequential character are used

create or replace function fn_check_sequencial_characters(p_str text)--ABCDE,AXDGE
returns boolean
language plpgsql
as $$
begin
      for i in 1..(length(p_str)-1)
	  loop
	      if ascii(substring(p_str,i+1,1))- ascii(substring(p_str,i,1)) != 1
		  then
		      return false;
		  end if;
	  end loop;
	  return true;
end;
$$

select fn_check_sequencial_characters('BCDEF')
select fn_check_sequencial_characters('ABDEG')

--Regular expression ti validate the pattern or structure of PAN Number--AAAAA1234A
Select *
from stg_pan_numbers_dataset
where pan_number ~'^[A-Z]{5}[0-9]{4}[A-Z]$'

---Valid and Invalid PAN Categorization

create or replace view vw_valid_invalid_pans 
as 
with cte_cleaned_pan as 
        (select distinct upper(trim(pan_number)) as pan_number
        from stg_pan_numbers_dataset
        where pan_number is not null
        and trim(pan_number) <> ''),
	 cte_valid_pans as 
	   (select * 
	    from cte_cleaned_pan
	    where fn_check_adjacent_characters(pan_number)=false
	    and fn_check_sequencial_characters(substring(pan_number,1,5)) = false
	    and fn_check_sequencial_characters(substring(pan_number,6,4))=false
	    and pan_number ~'^[A-Z]{5}[0-9]{4}[A-Z]$' )
select cln.pan_number
, case when vld.pan_number is not null 
             then 'valid PAN'
	   else 'invalid pan'
  end as status
  from cte_cleaned_pan cln
  left join cte_valid_pans vld on vld.pan_number = cln.pan_number;

select * from vw_valid_invalid_pans

--Summary report
* Total records processed
* Total valid PANs
* Total invalid PANs
* Total missing or incomplete PANs (if applicable)

with cte as 
     (select 
		    (select count(*) from stg_pan_numbers_dataset) as total_processed_records ,
			 count(*) filter (where status = 'valid PAN') as total_valid_pans,
			 count(*) filter(where status = 'invalid PAN') as total_invalid_pans
	  from vw_valid_invalid_pans)
select total_processed_records , total_valid_pans,total_invalid_pans,
(total_processed_records - (total_valid_pans + total_invalid_pans)) as total_missing_pans
from cte

















