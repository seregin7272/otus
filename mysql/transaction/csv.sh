#!/bin/bash

mysqlimport -d -L  -u root -psecret --ignore-lines=1 --lines-terminated-by='\n' --fields-terminated-by=','  --fields-enclosed-by='"' --verbose \
-c handle,title,body,vendor,types,tags,published,option1_name,option1_value,option2_name,option2_value,option3_name,option3_value,\
@variant_sku,@variant_grams,@variant_inventory_tracker,variant_inventory_qty,@variant_inventory_policy,@variant_fulfillment_service,\
variant_price,@variant_compare_price,@variant_requires_shipping,@variant_taxable,@variant_barcode,image_src,\
@image_alt,@gift_card,@seo_title,@seo_description,@google_shopping_google_product_category,@google_shopping_gender,@google_shopping_age_group,\
@google_shopping_mpn,@google_shopping_adwords_grouping,@google_shopping_adwords_labels,@google_shopping_condition,\
@google_shopping_custom_product,@google_shopping_custom_label_0,@google_shopping_custom_label_1,@google_shopping_custom_label_2,\
@google_shopping_custom_label_3,@google_shopping_custom_label_4,variant_image,@variant_weight_unit \
x_shop  /var/csv/tmp_product_csv_import.csv