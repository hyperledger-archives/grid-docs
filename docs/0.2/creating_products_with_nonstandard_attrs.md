# Creating Products with Non-Standard Attributes

<!--
  Copyright (c) 2018-2021 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

Grid is intended to align on open standards. In the event that additional,
non-standard attributes are required to define products, a non-default schema
should be added that defines the additional attributes alongside the GDSN 3.1
field. Additional attributes can then be defined in a YAML file similar to
<a href="/docs/0.2/references/product/additional_attributes.yaml"
download="additional_attributes.yaml">this one</a>.

{:start="1"}

1. Add the schema file that defines both the standard and non-standard
attributes to your docker container. An example of this schema can be found
<a href="/docs/0.2/references/product/nonstandard_product_schema.yaml"
download="nonstandard_product_schema.yaml">here</a>.

   ```
   $ docker cp nonstandard_product_schema.yaml gridd-alpha:/
   ```

1. Update the existing `gs1_product` schema if it exists on your circuit.
If a schema with that name doesn't exist, add it:

    ```
    $ grid schema update nonstandard_product_schema.yaml
    ```

1. Copy the additional attributes file into the docker container:

   ```
   $ docker cp additional_attributes.yaml gridd-alpha:/
   ```

1. Products can then be added using the command:

   ```
   root@gridd-alpha:/# grid product create \
   --owner myorg \
   --file product.xml \
   --file additional_attributes.yaml
   ```
