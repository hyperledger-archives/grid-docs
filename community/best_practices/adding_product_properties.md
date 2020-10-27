# Process for adding Product Attributes

Grid Product supports GS1 products and a subset of GS1 product properties. In
grid, the available product properties are defined in the product schema
definition file. This document covers the verification process used when adding
new product properties, which is intended to ensure the contents of the product
schema match the GS1 specifications.

## Sources used to do Verification

The following are used to perform verification of fields:
  * [Global Data Dictionary
](http://apps.gs1.org/GDD/bms/GDSN_31/Pages/biehome.aspx)

## Verification of Property definition

Only properties which exist in the GS1 standards may be included.
When adding a property, the following fields must be defined:
  * name
  * data_type
  * description
  * required
  * number_exponent - if the `data_type` is `number`
  * enum_options -  if the `data_type` is `enum`

When adding a new property, name and `data_type` must match the specification.
The name field should match the GS1 attribute name as closely as possible.
The `data_type` field is one of; Boolean, Number, String, Enum, Lat_Long. This
should match the data type defined in the GS1 standard. For example, brand name
is defined in the specification to be a string, so `data_type` must be String.
In the event that the there is not a data type use String as the data type.

The required field must always be set to `false`. All product properties are
optional (the properties used depend upon which GTIN is being defined). There
are no inherently required fields in the standard.

## Customization

Product schema may only contain properties which correspond to attributes in
the GS1 standards. There may be circumstances were it is desirable to add
additional fields that are not in the specification. This may not be done
with the default schema file, which is intended as a pure translation of the
GS1 product standards. However, the default schema may be modified prior to
import for a particular installation.

When customizing the product schema, it is strongly recommended that non-GS1
fields be prefixed with "ext:" so it remains clear that these are extensions
in the local installation and not part of the GS1-based schema provided as
part of Grid.  For example, an attribute called "myCustomAttribute" should be
named "ext:myCustomAttribute" in the customized schema file.
