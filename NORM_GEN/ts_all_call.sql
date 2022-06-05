---populate metadata with the sample data
select norm_gen.ts_all (						  				  
	 $${
     "title": "User account",
     "description":"all account details with DB mappings",
     "type": "array",
      "items": {
	              "$ref": "#/definitions/account"
                 },
     "db_mapping":{
     	   "db_schema":"norm"
     	            },
     "definitions": {
         "account":{
         "type": "object",
          "db_mapping": {
                  "db_table":"account",
                  "pk_col": "account_id",
                 "record_type": "account_record"
         },
         "properties": { 
             "account_id": {
                 "type": "number"
             },     
             "username": {
                 "type": "string"
             },
             "last_name": {
                 "type": "string"
             },
             "first_name": {
                 "type": "string"
             },
             "dob": {
                 "type": "string",
                 "format": "date",
                 "db_mapping":{                  
                   "db_col": "dob",
                   "db_type": "date"
                   }
             },
             "emails": {
                 "type": "array",
                 "items": {
                     "$ref": "#/definitions/email"
                 }
             },
             "phones": {
                 "type": "array",
                 "items": {
                     "$ref": "#/definitions/phone"
                 }
             }
         }
     },
         "email": {
                 "type": "object",
                 "db_mapping": {
                     "parent_fk_col": "account_id",
                     "record_type": "email_record",
                     "db_table": "email",
                     "pk_col":"email_id",      
                    "embedded":[
                        {"alias":"ep",
                         "db_table":"email_priority",
                         "pk_col":"email_priority_id",
                         "fk_col":"email_priority_id"
                         }
                         ]
                 },
             "properties": {
                     "email_address": {
                         "type": "string",
                         "db_mapping":{
                         "db_col":"email" 
                         }
                      },
                     "email_id": {
                         "type": "number"               
                     },
                     "email_priority": {
                         "type": "string",                      
                        "db_mapping":{
                        "db_col":"email_priority",
                        "db_source_alias":"ep" 
                            }
                     },
                     "email_priority_id": {
                         "type": "number"
                     }
                 }
         },
         "phone": {
             "type": "object",              
             "db_mapping": {
                 "parent_fk_col": "account_id",
                 "record_type": "phone_record",
                 "db_table":"phone",
                 "pk_col": "phone_id",
                  "embedded":[
                        {"alias":"pt",
                         "db_table":"phone_type",
                         "pk_col":"phone_type_id",
                         "fk_col":"phone_type_id"
                         }
                         ]
             },
             "properties": {
                 "phone_id": {
                     "type": "number"
                 },
                 "phone_type": {
                     "type": "string",                   
                        "db_mapping":{
                            "db_col":"phone_type",
                            "db_source_alias":"pt" 
                             }
                 },
                 "phone_number": {
                     "type": "string",                 
                     "db_mapping":{                  
                     "db_col": "phone"
                     }                  
                 },
                 "phone_type_id": {
                     "type": "number"
                 }
             }
         }
     }
 }
$$::json		 
 );
 
							   
---generate sql to create data types:
do $block$
declare v_sql text;
begin
select norm_gen.generate_types('User account') into v_sql;
execute v_sql;
end;
$block$;
--	generate select nested object

do $block$
declare v_sql text;
begin
select norm_gen.nested_root('User account') into v_sql;
raise notice 'SELECT: %' ,v_sql;
end;
$block$;

---generate funciton norm.account_search_by_ids

select * from norm_gen.generate_select_by_id_function('User account');

---test the result

select * from norm.account_search_by_ids(array [1,2]);

---generate generic searhc function

select norm_gen.generate_search_generic_function('User account');

---test the result

select norm.account_search_generic($${
"phone_type":"cell",
"email_priority":"primary",
"account":{"last_name":"johns",
     "emails":{"email_address":{"$like":"%gmail%"}},
     "dob":{"$gt":"1901-01-01"},
     "phones":{"phone_number":{"$like":"312%"}}
     }
}$$::json);



   