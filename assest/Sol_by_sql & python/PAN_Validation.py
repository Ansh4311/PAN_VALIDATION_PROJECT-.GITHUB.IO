import pandas as pd
import re

df = pd.read_excel('PAN Number Validation Dataset.xlsx')
#print(df.head(10))
print('Total records = ',len(df))
total_records = len(df)

df["Pan_Numbers"] = df['Pan_Numbers'].astype('string').str.strip().str.upper()
#print(df.head(10))

print('\n')
#print(df[df['Pan_Numbers']== ''])
#print(df[df['Pan_Numbers'].isna()])

print('Total records = ', len(df))
df = df.replace({"Pan_Numbers":''},pd.NA).dropna(subset="Pan_Numbers")
#print(df[df['Pan_Numbers']== ''])
#print(df[df['Pan_Numbers'].isna()])

print('Total records =',len(df))
print('Unique = ', df["Pan_Numbers"].nunique())

df = df.drop_duplicates(subset = "Pan_Numbers",keep='first')
print('TOTAL RECORDS = ',len(df))

#VALIDATION 
def has_adjacent_repitition(pan):
    for i in range(len(pan)-1):
        if pan[i] == pan[i+1]:
            return True
        return False
    
print(has_adjacent_repitition('AABCD'))
print(has_adjacent_repitition('FGHHH'))
print(has_adjacent_repitition('ABCDX'))  
print(has_adjacent_repitition('MNJPQ'))

print('\n')

def is_sequencial(pan): #ABCDE 
    for i in range(len(pan)-1):
        if ord(pan[i+1]) - ord(pan[i]) != 1:
            return False
    return True

print(is_sequencial('ABCDE'))
print(is_sequencial('MNOPQ'))
print(is_sequencial('ABCXY'))
print(is_sequencial('XYZAB'))

print('\n')

def is_valid_pan(pan):
    if len(pan) != 10:
        return False
    
    if not re.match(r'^[A-Z]{5}[0-9]{4}[A-Z]$', pan):
        return False
    
    if has_adjacent_repitition(pan):
        return False
    if is_sequencial(pan):
        return False
    
    return True

df["status"] = df["Pan_Numbers"].apply(lambda x: "valid" if is_valid_pan(x) else "Invalid")
print(df.head(10))

valid_cnt = (df["status"] == 'valid').sum()
invalid_cnt = (df["status"] == 'Invalid').sum()
missing_cnt = total_records - (valid_cnt + invalid_cnt)
print('Total records = ', total_records)
print('Valid = ', valid_cnt)
print('Invalid =',invalid_cnt)
print('Missing = ', missing_cnt)

df_summary =pd.DataFrame({"TOTAL RECORDS": [total_records]
                        ,"TOTAL VALID COUNT": [valid_cnt]
                        , "TOTAL INVALID COUNT": [invalid_cnt]
                        , "TOTAL MISSING PANS": [missing_cnt]})
print(df_summary.head())
                          
with pd.ExcelWriter("PAN VALIDATION RESULT PY.xlsx") as writer:
    df.to_excel(writer,sheet_name= "PAN Validation py",index = False)
    df_summary.to_excel(writer,sheet_name= "SUMMARY py",index = False)
    