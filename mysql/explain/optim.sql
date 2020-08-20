
CREATE INDEX client_campaigns_c_ch_last_idx on client_campaigns(campaign, channel, last_at, client_id);

CREATE INDEX client_orders_type_idx on  client_orders(`type`, client_id);

CREATE INDEX clients_idx_ex on  clients (subscribed_email, email, deleted_at, bonus);


SHOW PROFILES;
-- 1.29018


SELECT clnt.id, clnt.name, clnt.bonus, clnt.email
		FROM clients clnt
		WHERE 
			clnt.bonus > 50 
			and clnt.subscribed_email = 1  
			and clnt.email REGEXP '(.*)@(.*)\\.(.*)'
			and clnt.deleted_at is null
			and clnt.id in (
				SELECT 
					client_id 
				FROM  
					client_ordersSHOW PROFILES;
				where SHOW PROFILES;
					`type` = 'client'
			)
		and(
		clnt.id in (
				SELECT 
					client_id
				FROM  
					 client_campaigns 
 					 USE INDEX (client_campaigns_c_ch_last_idx)
				WHERE 
					last_at  < '2020-07-01 07:03:38'
					and channel = 'email'
					and campaign = 'bonusAfterOrder' 
) or clnt.id not in (
				SELECT 
					client_id
				FROM 
					client_campaigns 
					USE INDEX (client_campaigns_c_ch_last_idx)
				WHERE  
					channel = 'email'
					and campaign = 'bonusAfterOrder' 
					
))
LIMIT 12000;


-- EXPLAIN 


-- id|select_type|table           |partitions|type |possible_keys                                                                                    |key                           |key_len|ref               |rows  |filtered|Extra                             |
-- --|-----------|----------------|----------|-----|-------------------------------------------------------------------------------------------------|------------------------------|-------|------------------|------|--------|----------------------------------|
--  1|PRIMARY    |clnt            |          |ref  |PRIMARY,clients_idx_ex                                                                           |clients_idx_ex                |1      |const             |481921|    3.33|Using index condition; Using where|
--  1|PRIMARY    |client_orders   |          |ref  |client_orders_client_id_order_id_type_unique,client_orders_client_id_index,client_orders_type_idx|client_orders_type_idx        |6      |const,flor.clnt.id|     1|   100.0|Using index; FirstMatch(clnt)     |
--  4|SUBQUERY   |client_campaigns|          |ref  |client_campaigns_c_ch_last_idx                                                                   |client_campaigns_c_ch_last_idx|1534   |const,const       |550381|   100.0|Using index                       |
--  3|SUBQUERY   |client_campaigns|          |range|client_campaigns_c_ch_last_idx                                                                   |client_campaigns_c_ch_last_idx|1539   |                  |326540|   100.0|Using where; Using index          |



-- EXPLAIN  JSON

{
  "query_block": {
    "select_id": 1,
    "cost_info": {
      "query_cost": "150848.57"
    },
    "nested_loop": [
      {
        "table": {
          "table_name": "clnt",
          "access_type": "ref",
          "possible_keys": [
            "PRIMARY",
            "clients_idx_ex"
          ],
          "key": "clients_idx_ex",
          "used_key_parts": [
            "subscribed_email"
          ],
          "key_length": "1",
          "ref": [
            "const"
          ],
          "rows_examined_per_scan": 481921,
          "rows_produced_per_join": 16062,
          "filtered": "3.33",
          "index_condition": "((`flor`.`clnt`.`bonus` > 50) and (`flor`.`clnt`.`email` regexp '(.*)@(.*)\\\\.(.*)') and isnull(`flor`.`clnt`.`deleted_at`))",
          "cost_info": {
            "read_cost": "33159.00",
            "eval_cost": "3212.49",
            "prefix_cost": "129543.20",
            "data_read_per_join": "127M"
          },
          "used_columns": [
            "id",
            "name",
            "email",
            "deleted_at",
            "bonus",
            "subscribed_email"
          ],
          "attached_condition": "(<in_optimizer>(`flor`.`clnt`.`id`,`flor`.`clnt`.`id` in ( <materialize> (/* select#3 */ select `flor`.`client_campaigns`.`client_id` from `flor`.`client_campaigns` USE INDEX (`client_campaigns_c_ch_last_idx`) where ((`flor`.`client_campaigns`.`last_at` < '2020-07-01 07:03:38') and (`flor`.`client_campaigns`.`channel` = 'email') and (`flor`.`client_campaigns`.`campaign` = 'bonusAfterOrder')) ), <primary_index_lookup>(`flor`.`clnt`.`id` in <temporary table> on <auto_key> where ((`flor`.`clnt`.`id` = `materialized-subquery`.`client_id`))))) or (not(<in_optimizer>(`flor`.`clnt`.`id`,`flor`.`clnt`.`id` in ( <materialize> (/* select#4 */ select `flor`.`client_campaigns`.`client_id` from `flor`.`client_campaigns` USE INDEX (`client_campaigns_c_ch_last_idx`) where ((`flor`.`client_campaigns`.`channel` = 'email') and (`flor`.`client_campaigns`.`campaign` = 'bonusAfterOrder')) ), <primary_index_lookup>(`flor`.`clnt`.`id` in <temporary table> on <auto_key> where ((`flor`.`clnt`.`id` = `materialized-subquery`.`client_id`))))))))",
          "attached_subqueries": [
            {
              "table": {
                "table_name": "<materialized_subquery>",
                "access_type": "eq_ref",
                "key": "<auto_key>",
                "key_length": "4",
                "rows_examined_per_scan": 1,
                "materialized_from_subquery": {
                  "using_temporary_table": true,
                  "dependent": true,
                  "cacheable": false,
                  "query_block": {
                    "select_id": 4,
                    "cost_info": {
                      "query_cost": "201807.20"
                    },
                    "table": {
                      "table_name": "client_campaigns",
                      "access_type": "ref",
                      "possible_keys": [
                        "client_campaigns_c_ch_last_idx"
                      ],
                      "key": "client_campaigns_c_ch_last_idx",
                      "used_key_parts": [
                        "campaign",
                        "channel"
                      ],
                      "key_length": "1534",
                      "ref": [
                        "const",
                        "const"
                      ],
                      "rows_examined_per_scan": 550381,
                      "rows_produced_per_join": 550381,
                      "filtered": "100.00",
                      "using_index": true,
                      "cost_info": {
                        "read_cost": "91731.00",
                        "eval_cost": "110076.20",
                        "prefix_cost": "201807.20",
                        "data_read_per_join": "1G"
                      },
                      "used_columns": [
                        "client_id",
                        "channel",
                        "campaign"
                      ]
                    }
                  }
                }
              }
            },
            {
              "table": {
                "table_name": "<materialized_subquery>",
                "access_type": "eq_ref",
                "key": "<auto_key>",
                "key_length": "4",
                "rows_examined_per_scan": 1,
                "materialized_from_subquery": {
                  "using_temporary_table": true,
                  "dependent": true,
                  "cacheable": false,
                  "query_block": {
                    "select_id": 3,
                    "cost_info": {
                      "query_cost": "134538.41"
                    },
                    "table": {
                      "table_name": "client_campaigns",
                      "access_type": "range",
                      "possible_keys": [
                        "client_campaigns_c_ch_last_idx"
                      ],
                      "key": "client_campaigns_c_ch_last_idx",
                      "used_key_parts": [
                        "campaign",
                        "channel",
                        "last_at"
                      ],
                      "key_length": "1539",
                      "rows_examined_per_scan": 326540,
                      "rows_produced_per_join": 122294,
                      "filtered": "100.00",
                      "using_index": true,
                      "cost_info": {
                        "read_cost": "61154.28",
                        "eval_cost": "24458.93",
                        "prefix_cost": "134538.41",
                        "data_read_per_join": "274M"
                      },
                      "used_columns": [
                        "client_id",
                        "channel",
                        "campaign",
                        "last_at"
                      ],
                      "attached_condition": "((`flor`.`client_campaigns`.`last_at` < '2020-07-01 07:03:38') and (`flor`.`client_campaigns`.`channel` = 'email') and (`flor`.`client_campaigns`.`campaign` = 'bonusAfterOrder'))"
                    }
                  }
                }
              }
            }
          ]
        }
      },
      {
        "table": {
          "table_name": "client_orders",
          "access_type": "ref",
          "possible_keys": [
            "client_orders_client_id_order_id_type_unique",
            "client_orders_client_id_index",
            "client_orders_type_idx"
          ],
          "key": "client_orders_type_idx",
          "used_key_parts": [
            "type",
            "client_id"
          ],
          "key_length": "6",
          "ref": [
            "const",
            "flor.clnt.id"
          ],
          "rows_examined_per_scan": 1,
          "rows_produced_per_join": 16062,
          "filtered": "100.00",
          "using_index": true,
          "first_match": "clnt",
          "cost_info": {
            "read_cost": "16074.73",
            "eval_cost": "3212.49",
            "prefix_cost": "150848.57",
            "data_read_per_join": "47M"
          },
          "used_columns": [
            "client_id",
            "type"
          ]
        }
      }
    ]
  }
}















