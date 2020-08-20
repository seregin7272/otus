

SHOW PROFILES;
-- 3.470593

select `clients`.`id`, `name`, `bonus`, `email` 
from `clients` 
where 
`bonus` > 50 
and (
	`subscribed_email` = 1  and `email` REGEXP '(.*)@(.*)\\.(.*)'
	) 
and exists
	(
		select * from `client_orders` where `clients`.`id` = `client_orders`.`client_id` and `type` = 'client'
	) 
and (
exists 
		(
		select * from `client_campaigns` 
		where 
			`clients`.`id` = `client_campaigns`.`client_id` 
			and `campaign` = 'bonusAfterOrder' 
			and `channel` = 'email' 
 		    and `last_at` < '2020-07-01 07:03:38'
		) 
		or 
		not exists (
			select * from `client_campaigns` 
			where 
			`clients`.`id` = `client_campaigns`.`client_id` 
			and `campaign` = 'bonusAfterOrder' 
			and `channel` = 'email'
		)
) 
and `clients`.`deleted_at` is null order by `clients`.`id` asc limit 12000;



-- EXPLAIN


-- id|select_type       |table           |partitions|type  |possible_keys                                                                                                                                                                                                             |key                                               |key_len|ref                        |rows |filtered|Extra      |
-- --|------------------|----------------|----------|------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------|-------|---------------------------|-----|--------|-----------|
--  1|PRIMARY           |clients         |          |index |clients_idx_ex                                                                                                                                                                                                            |PRIMARY                                           |4      |                           |24000|    1.67|Using where|
--  4|DEPENDENT SUBQUERY|client_campaigns|          |eq_ref|client_campaigns_channel_campaign_client_id_unique,client_campaigns_client_id_index,client_campaigns_channel_index,client_campaigns_campaign_index,client_campaigns_c_ch_last_idx                                         |client_campaigns_channel_campaign_client_id_unique|1538   |const,const,flor.clients.id|    1|   100.0|Using index|
--  3|DEPENDENT SUBQUERY|client_campaigns|          |eq_ref|client_campaigns_channel_campaign_client_id_unique,client_campaigns_client_id_index,client_campaigns_channel_index,client_campaigns_campaign_index,client_campaigns_last_at_opened_at_index,client_campaigns_c_ch_last_idx|client_campaigns_channel_campaign_client_id_unique|1538   |const,const,flor.clients.id|    1|    50.0|Using where|
--  2|DEPENDENT SUBQUERY|client_orders   |          |ref   |client_orders_client_id_order_id_type_unique,client_orders_client_id_index,client_orders_type_idx                                                                                                                         |client_orders_type_idx                            |6      |const,flor.clients.id      |    1|   100.0|Using index|






-- EXPLAIN JSON

{
  "query_block": {
    "select_id": 1,
    "cost_info": {
      "query_cost": "129543.20"
    },
    "ordering_operation": {
      "using_filesort": false,
      "table": {
        "table_name": "clients",
        "access_type": "index",
        "possible_keys": [
          "clients_idx_ex"
        ],
        "key": "PRIMARY",
        "used_key_parts": [
          "id"
        ],
        "key_length": "4",
        "rows_examined_per_scan": 24000,
        "rows_produced_per_join": 16062,
        "filtered": "1.67",
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
        "attached_condition": "((`flor`.`clients`.`subscribed_email` <=> 1) and ((`flor`.`clients`.`bonus` > 50) and (`flor`.`clients`.`email` regexp '(.*)@(.*)\\\\.(.*)') and exists(/* select#2 */ select 1 from `flor`.`client_orders` where ((`flor`.`clients`.`id` = `flor`.`client_orders`.`client_id`) and (`flor`.`client_orders`.`type` = 'client'))) and (exists(/* select#3 */ select 1 from `flor`.`client_campaigns` where ((`flor`.`clients`.`id` = `flor`.`client_campaigns`.`client_id`) and (`flor`.`client_campaigns`.`campaign` = 'bonusAfterOrder') and (`flor`.`client_campaigns`.`channel` = 'email') and (`flor`.`client_campaigns`.`last_at` < '2020-07-01 07:03:38'))) or (not(exists(/* select#4 */ select 1 from `flor`.`client_campaigns` where ((`flor`.`clients`.`id` = `flor`.`client_campaigns`.`client_id`) and (`flor`.`client_campaigns`.`campaign` = 'bonusAfterOrder') and (`flor`.`client_campaigns`.`channel` = 'email')))))) and isnull(`flor`.`clients`.`deleted_at`)))",
        "attached_subqueries": [
          {
            "dependent": true,
            "cacheable": false,
            "query_block": {
              "select_id": 4,
              "cost_info": {
                "query_cost": "1.20"
              },
              "table": {
                "table_name": "client_campaigns",
                "access_type": "eq_ref",
                "possible_keys": [
                  "client_campaigns_channel_campaign_client_id_unique",
                  "client_campaigns_client_id_index",
                  "client_campaigns_channel_index",
                  "client_campaigns_campaign_index",
                  "client_campaigns_c_ch_last_idx"
                ],
                "key": "client_campaigns_channel_campaign_client_id_unique",
                "used_key_parts": [
                  "channel",
                  "campaign",
                  "client_id"
                ],
                "key_length": "1538",
                "ref": [
                  "const",
                  "const",
                  "flor.clients.id"
                ],
                "rows_examined_per_scan": 1,
                "rows_produced_per_join": 1,
                "filtered": "100.00",
                "using_index": true,
                "cost_info": {
                  "read_cost": "1.00",
                  "eval_cost": "0.20",
                  "prefix_cost": "1.20",
                  "data_read_per_join": "2K"
                },
                "used_columns": [
                  "client_id",
                  "channel",
                  "campaign"
                ]
              }
            }
          },
          {
            "dependent": true,
            "cacheable": false,
            "query_block": {
              "select_id": 3,
              "cost_info": {
                "query_cost": "1.20"
              },
              "table": {
                "table_name": "client_campaigns",
                "access_type": "eq_ref",
                "possible_keys": [
                  "client_campaigns_channel_campaign_client_id_unique",
                  "client_campaigns_client_id_index",
                  "client_campaigns_channel_index",
                  "client_campaigns_campaign_index",
                  "client_campaigns_last_at_opened_at_index",
                  "client_campaigns_c_ch_last_idx"
                ],
                "key": "client_campaigns_channel_campaign_client_id_unique",
                "used_key_parts": [
                  "channel",
                  "campaign",
                  "client_id"
                ],
                "key_length": "1538",
                "ref": [
                  "const",
                  "const",
                  "flor.clients.id"
                ],
                "rows_examined_per_scan": 1,
                "rows_produced_per_join": 0,
                "filtered": "50.00",
                "cost_info": {
                  "read_cost": "1.00",
                  "eval_cost": "0.10",
                  "prefix_cost": "1.20",
                  "data_read_per_join": "1K"
                },
                "used_columns": [
                  "client_id",
                  "channel",
                  "campaign",
                  "last_at"
                ],
                "attached_condition": "(`flor`.`client_campaigns`.`last_at` < '2020-07-01 07:03:38')"
              }
            }
          },
          {
            "dependent": true,
            "cacheable": false,
            "query_block": {
              "select_id": 2,
              "cost_info": {
                "query_cost": "1.33"
              },
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
                  "flor.clients.id"
                ],
                "rows_examined_per_scan": 1,
                "rows_produced_per_join": 1,
                "filtered": "100.00",
                "using_index": true,
                "cost_info": {
                  "read_cost": "1.00",
                  "eval_cost": "0.33",
                  "prefix_cost": "1.33",
                  "data_read_per_join": "4K"
                },
                "used_columns": [
                  "client_id",
                  "type"
                ]
              }
            }
          }
        ]
      }
    }
  }
}





