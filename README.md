Oracle Apex AnyChart Region Plugin
+
JavaScript file to customize and facilitate initialization of an AnyChart object

Plugin File is compatible with Apex 4.2 and up.
Tested with AnyGantt 4.3.0 and AnyChart 6

The point is to be able to deal with:
- large data sets
- no column limitations imposed by the chart series SQL verification (no obligated number ID column eg) 
- keep settings and data separated

Main points:
- data should be serialized XML: the XML has to follow the AnyGantt XML specs
- settings too. Settings should include the correct data tag.
- all data retrieval is in ajax

Pay attention to:
The data attachment node in settings has to be the correct one according to chart, such as <resource_chart>,<project_chart>,...
The data xml then also has to be wrapped in the same data tag.
This way both XMLs can be combined.

Issues:
- settings as a textarea is limited to 4000 characters due to an apex limitation. 
- the apexrefresh event should be bound to the actual container and not the generated custom one
- unsure of IE8 compatibility

MIT licensed.