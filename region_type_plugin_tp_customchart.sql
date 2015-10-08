set define off
set verify off
set feedback off
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
begin wwv_flow.g_import_in_progress := true; end;
/
 
--       AAAA       PPPPP   EEEEEE  XX      XX
--      AA  AA      PP  PP  EE       XX    XX
--     AA    AA     PP  PP  EE        XX  XX
--    AAAAAAAAAA    PPPPP   EEEE       XXXX
--   AA        AA   PP      EE        XX  XX
--  AA          AA  PP      EE       XX    XX
--  AA          AA  PP      EEEEEE  XX      XX
prompt  Set Credentials...
 
begin
 
  -- Assumes you are running the script connected to SQL*Plus as the Oracle user APEX_040200 or as the owner (parsing schema) of the application.
  wwv_flow_api.set_security_group_id(p_security_group_id=>nvl(wwv_flow_application_install.get_workspace_id,25696002251374162));
 
end;
/

begin wwv_flow.g_import_in_progress := true; end;
/
begin 

select value into wwv_flow_api.g_nls_numeric_chars from nls_session_parameters where parameter='NLS_NUMERIC_CHARACTERS';

end;

/
begin execute immediate 'alter session set nls_numeric_characters=''.,''';

end;

/
begin wwv_flow.g_browser_language := 'en'; end;
/
prompt  Check Compatibility...
 
begin
 
-- This date identifies the minimum version required to import this file.
wwv_flow_api.set_version(p_version_yyyy_mm_dd=>'2012.01.01');
 
end;
/

prompt  Set Application ID...
 
begin
 
   -- SET APPLICATION ID
   wwv_flow.g_flow_id := nvl(wwv_flow_application_install.get_application_id,122119);
   wwv_flow_api.g_id_offset := nvl(wwv_flow_application_install.get_offset,0);
null;
 
end;
/

prompt  ...ui types
--
 
begin
 
null;
 
end;
/

prompt  ...plugins
--
--application/shared_components/plugins/region_type/tp_customchart
 
begin
 
wwv_flow_api.create_plugin (
  p_id => 526134514221575646 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_type => 'REGION TYPE'
 ,p_name => 'TP.CUSTOMCHART'
 ,p_display_name => 'Custom Chart XML'
 ,p_supported_ui_types => 'DESKTOP'
 ,p_image_prefix => '#PLUGIN_PREFIX#'
 ,p_plsql_code => 
'-- Helper procedure, and for future improvement if size would ever '||unistr('\000a')||
'-- be > 32k'||unistr('\000a')||
'PROCEDURE output_clob ( p_clob IN OUT NOCOPY CLOB )'||unistr('\000a')||
'IS'||unistr('\000a')||
'  l_size    NUMBER;'||unistr('\000a')||
'  l_read    INTEGER := 32767;'||unistr('\000a')||
'  l_offset  INTEGER :=1;'||unistr('\000a')||
'  l_buffer  VARCHAR2(32767);'||unistr('\000a')||
'BEGIN'||unistr('\000a')||
'   SELECT dbms_lob.getlength(p_clob) INTO l_size FROM dual;'||unistr('\000a')||
'   '||unistr('\000a')||
'   LOOP'||unistr('\000a')||
'     dbms_lob.read(p_clob, l_read, l_offset, l_buffer);'||unistr('\000a')||
'     l_offset := l_offset +'||
' l_read;'||unistr('\000a')||
'     htp.prn(l_buffer);'||unistr('\000a')||
'     EXIT WHEN l_offset >= l_size;'||unistr('\000a')||
'   END LOOP;'||unistr('\000a')||
'EXCEPTION WHEN OTHERS THEN'||unistr('\000a')||
'  htp.p(''output_clob'');'||unistr('\000a')||
'  RAISE;'||unistr('\000a')||
'END;'||unistr('\000a')||
''||unistr('\000a')||
'FUNCTION render_custom_chart'||unistr('\000a')||
'( p_region in apex_plugin.t_region'||unistr('\000a')||
', p_plugin in apex_plugin.t_plugin'||unistr('\000a')||
', p_is_printer_friendly in boolean'||unistr('\000a')||
')'||unistr('\000a')||
'RETURN apex_plugin.t_region_render_result'||unistr('\000a')||
'IS'||unistr('\000a')||
'  -- ATTRIBUTE MAPPING'||unistr('\000a')||
'  --------------------'||unistr('\000a')||
'  -- APPLICATION SCOPE'||unistr('\000a')||
'  l'||
'_chart_js_folder    VARCHAR2(4000)  := p_plugin.attribute_01;'||unistr('\000a')||
'  l_chart_main_js      VARCHAR2(4000)  := p_plugin.attribute_02;'||unistr('\000a')||
'  l_chart_html5_js     VARCHAR2(4000)  := p_plugin.attribute_03;'||unistr('\000a')||
'  l_chart_swf_folder   VARCHAR2(4000)  := p_plugin.attribute_04;'||unistr('\000a')||
'  l_chart_main_swf     VARCHAR2(4000)  := p_plugin.attribute_05;'||unistr('\000a')||
'  l_chart_preload_swf  VARCHAR2(4000)  := p_plugin.attribute_06;'||unistr('\000a')||
'  l_gantt_js_'||
'folder    VARCHAR2(4000)  := p_plugin.attribute_07;'||unistr('\000a')||
'  l_gantt_main_js      VARCHAR2(4000)  := p_plugin.attribute_08;'||unistr('\000a')||
'  l_gantt_swf_folder   VARCHAR2(4000)  := p_plugin.attribute_09;'||unistr('\000a')||
'  l_gantt_main_swf     VARCHAR2(4000)  := p_plugin.attribute_10;'||unistr('\000a')||
'  l_gantt_preload_swf  VARCHAR2(4000)  := p_plugin.attribute_11;'||unistr('\000a')||
''||unistr('\000a')||
'  -- COMPONENT SCOPE'||unistr('\000a')||
'  l_chart_type         VARCHAR2(10)    := p_region.attribute_01;'||unistr('\000a')||
' '||
' l_render_type        VARCHAR2(20)    := p_region.attribute_02;'||unistr('\000a')||
'  l_data_type          VARCHAR2(20)    := p_region.attribute_04; -- Gantt type PROJECT / RESOURCE, or just DATA for Chart'||unistr('\000a')||
'  l_height             VARCHAR2(10)    := p_region.attribute_05;'||unistr('\000a')||
'  l_width              VARCHAR2(10)    := p_region.attribute_06;'||unistr('\000a')||
'  l_handlers           VARCHAR2(4000)  := NVL(p_region.attribute_07, ''{}''); -- js ob'||
'ject with js handlers for chart'||unistr('\000a')||
'  '||unistr('\000a')||
'  -- LOCAL VARIABLES'||unistr('\000a')||
'  ------------------'||unistr('\000a')||
'  l_result             apex_plugin.t_region_render_result;'||unistr('\000a')||
'  l_region_id          VARCHAR2(100);  '||unistr('\000a')||
'  l_file_prefix        VARCHAR2(1000) := p_plugin.file_prefix;'||unistr('\000a')||
'  l_ajax_ident         VARCHAR2(200);'||unistr('\000a')||
'  l_main_swf           VARCHAR2(2000);'||unistr('\000a')||
'  l_preload_swf        VARCHAR2(2000);'||unistr('\000a')||
'BEGIN'||unistr('\000a')||
''||unistr('\000a')||
'  APEX_PLUGIN_UTIL.DEBUG_REGION ( '||unistr('\000a')||
'   '||
' p_plugin, '||unistr('\000a')||
'    p_region'||unistr('\000a')||
'  );'||unistr('\000a')||
'  '||unistr('\000a')||
'  IF l_chart_type = ''CHART'' THEN'||unistr('\000a')||
'    apex_javascript.add_library ('||unistr('\000a')||
'      p_name           => l_chart_main_js,'||unistr('\000a')||
'      p_directory      => l_chart_js_folder,'||unistr('\000a')||
'      p_skip_extension => TRUE,'||unistr('\000a')||
'      p_version        => NULL'||unistr('\000a')||
'    );'||unistr('\000a')||
'    '||unistr('\000a')||
'    apex_javascript.add_library ('||unistr('\000a')||
'      p_name           => l_chart_html5_js,'||unistr('\000a')||
'      p_directory      => l_chart_js_folder,'||unistr('\000a')||
'      p_skip_e'||
'xtension => TRUE,'||unistr('\000a')||
'      p_version        => NULL'||unistr('\000a')||
'    );'||unistr('\000a')||
'    '||unistr('\000a')||
'    l_main_swf    := l_chart_swf_folder||l_chart_main_swf;'||unistr('\000a')||
'    l_preload_swf := l_chart_swf_folder||l_chart_preload_swf;'||unistr('\000a')||
'  ELSE'||unistr('\000a')||
'    apex_javascript.add_library ('||unistr('\000a')||
'      p_name           => l_gantt_main_js,'||unistr('\000a')||
'      p_directory      => l_gantt_js_folder,'||unistr('\000a')||
'      p_skip_extension => TRUE,'||unistr('\000a')||
'      p_version        => NULL'||unistr('\000a')||
'    );'||unistr('\000a')||
'    '||unistr('\000a')||
'    l_main_swf'||
'    := l_gantt_swf_folder||l_gantt_main_swf;'||unistr('\000a')||
'    l_preload_swf := l_gantt_swf_folder||l_gantt_preload_swf;'||unistr('\000a')||
'  END IF;'||unistr('\000a')||
'  '||unistr('\000a')||
'  apex_javascript.add_library ('||unistr('\000a')||
'    p_name      => ''apex.custom.chart.min'','||unistr('\000a')||
'    p_directory => l_file_prefix,'||unistr('\000a')||
'    p_version   => NULL'||unistr('\000a')||
'  );'||unistr('\000a')||
'  '||unistr('\000a')||
'  -- generate region html'||unistr('\000a')||
'  l_region_id := ''cc_''||COALESCE(p_region.static_id, TO_CHAR(p_region.id));'||unistr('\000a')||
'  '||unistr('\000a')||
'  htp.p(''<div id="''||l_region_id|'||
'|''"></div>'');'||unistr('\000a')||
'  '||unistr('\000a')||
'  l_data_type := CASE l_data_type '||unistr('\000a')||
'                 WHEN ''PROJECT'' THEN ''project_chart'' '||unistr('\000a')||
'                 WHEN ''RESOURCE'' THEN ''resource_chart'' '||unistr('\000a')||
'                 ELSE ''data'' '||unistr('\000a')||
'                 END;'||unistr('\000a')||
'  l_ajax_ident :=  APEX_PLUGIN.GET_AJAX_IDENTIFIER ;'||unistr('\000a')||
'  apex_debug.message(''voor onload code'');'||unistr('\000a')||
'  apex_debug.message(''main swf: ''||l_main_swf);'||unistr('\000a')||
'  apex_debug.message(''preload swf: ''||l_pre'||
'load_swf);'||unistr('\000a')||
'  -- js'||unistr('\000a')||
'  apex_javascript.add_onload_code (  '||unistr('\000a')||
'    ''apex.custom.chart.add('''||unistr('\000a')||
'    ||   ''$("#''|| l_region_id ||''"),'''||unistr('\000a')||
'    ||   '' {"type":"''|| l_chart_type ||''"'''||unistr('\000a')||
'    ||   '' ,"rendertype":"''|| l_render_type ||''"'''||unistr('\000a')||
'    ||   '' ,"swfFile": "''|| l_main_swf ||''"'''||unistr('\000a')||
'    ||   '' ,"preloaderFile": "''|| l_preload_swf ||''"'''||unistr('\000a')||
'    ||   '' ,"width":"''||l_width||''"'''||unistr('\000a')||
'    ||   '' ,"height":"''||l_height||''"'''||unistr('\000a')||
'    ||  '||
' '' ,"ajax":'''||unistr('\000a')||
'    ||   ''    {"data":'''||unistr('\000a')||
'    ||   ''      {url: "wwv_flow.show"'''||unistr('\000a')||
'    ||   ''      , data: {'''||unistr('\000a')||
'    ||   ''        p_flow_id : $v("pFlowId")'''||unistr('\000a')||
'    ||   ''      , p_flow_step_id : $v("pFlowStepId")'''||unistr('\000a')||
'    ||   ''      , p_instance : $v("pInstance")'''||unistr('\000a')||
'    ||   ''      , p_request : "PLUGIN=''|| l_ajax_ident ||''"'''||unistr('\000a')||
'    ||   ''      , x01 : "DATA"'''||unistr('\000a')||
'    ||   ''      }'''||unistr('\000a')||
'    ||   ''      , dataType: "xml"}'''||unistr('\000a')||
'  '||
'  ||   ''    , "defaults":'''||unistr('\000a')||
'    ||   ''      {url: "wwv_flow.show"'''||unistr('\000a')||
'    ||   ''      , data: {'''||unistr('\000a')||
'    ||   ''        p_flow_id : $v("pFlowId")'''||unistr('\000a')||
'    ||   ''      , p_flow_step_id : $v("pFlowStepId")'''||unistr('\000a')||
'    ||   ''      , p_instance : $v("pInstance")'''||unistr('\000a')||
'    ||   ''      , p_request : "PLUGIN=''|| l_ajax_ident ||''"'''||unistr('\000a')||
'    ||   ''      , x01 : "DEFAULTS"'''||unistr('\000a')||
'    ||   ''      }'''||unistr('\000a')||
'    ||   ''      , dataType: "xml"}'''||unistr('\000a')||
'    ||  '||
' ''    }'''||unistr('\000a')||
'    ||   '' ,"chartType":"''|| l_data_type ||''"'''||unistr('\000a')||
'    ||   '' ,"eventHandlers": ''|| l_handlers'||unistr('\000a')||
'    ||   ''}'''||unistr('\000a')||
'    ||   '');'''||unistr('\000a')||
'  );'||unistr('\000a')||
'  apex_debug.message(''na onload code'');'||unistr('\000a')||
' RETURN l_result;'||unistr('\000a')||
'END;'||unistr('\000a')||
''||unistr('\000a')||
''||unistr('\000a')||
'FUNCTION ajax_custom_chart'||unistr('\000a')||
'( p_region in apex_plugin.t_region'||unistr('\000a')||
', p_plugin in apex_plugin.t_plugin '||unistr('\000a')||
')'||unistr('\000a')||
'RETURN apex_plugin.t_region_ajax_result'||unistr('\000a')||
'IS'||unistr('\000a')||
'  -- ATTRIBUTE MAPPING'||unistr('\000a')||
'  --------------------'||unistr('\000a')||
'  -- APPLICATI'||
'ON SCOPE'||unistr('\000a')||
''||unistr('\000a')||
'  -- COMPONENT SCOPE'||unistr('\000a')||
'  l_defaults           CLOB            := p_region.attribute_03;'||unistr('\000a')||
'  l_defaults2          CLOB            := p_region.attribute_08;'||unistr('\000a')||
'  l_defaults3          CLOB            := p_region.attribute_09;'||unistr('\000a')||
'  '||unistr('\000a')||
'  -- LOCAL VARIABLES'||unistr('\000a')||
'  ------------------'||unistr('\000a')||
'  l_sql                VARCHAR2(32767) := p_region.source;'||unistr('\000a')||
'  l_result             apex_plugin.t_region_ajax_result;'||unistr('\000a')||
'  l_request  '||
'          VARCHAR2(100)   := apex_application.g_x01;'||unistr('\000a')||
'  l_column_value_list  apex_plugin_util.t_column_value_list2;'||unistr('\000a')||
'  l_chart_xml          CLOB;'||unistr('\000a')||
'BEGIN'||unistr('\000a')||
'  CASE l_request'||unistr('\000a')||
'  WHEN ''DEFAULTS'' THEN'||unistr('\000a')||
'    /* VANROTH Added extra defaults values. Attribute 08 and 09 are extra textareas */'||unistr('\000a')||
'    l_defaults := l_defaults || l_defaults2;'||unistr('\000a')||
'    l_defaults := l_defaults || l_defaults3;'||unistr('\000a')||
''||unistr('\000a')||
'    output_clob(l_defaults);'||unistr('\000a')||
'  W'||
'HEN ''DATA'' THEN'||unistr('\000a')||
'    l_column_value_list :='||unistr('\000a')||
'      apex_plugin_util.get_data2 ('||unistr('\000a')||
'          p_sql_statement    => l_sql,'||unistr('\000a')||
'          p_min_columns      => 1,'||unistr('\000a')||
'          p_max_columns      => 1,'||unistr('\000a')||
'          p_component_name   => p_region.name,'||unistr('\000a')||
'          p_first_row        => 1,'||unistr('\000a')||
'          p_max_rows         => 1);'||unistr('\000a')||
'    -- only 1 record is expected.'||unistr('\000a')||
'    IF l_column_value_list.exists(1)'||unistr('\000a')||
'      AND l_column_value'||
'_list(1).value_list.exists(1)'||unistr('\000a')||
'    THEN'||unistr('\000a')||
'      l_chart_xml := l_column_value_list(1).value_list(1).clob_value;'||unistr('\000a')||
'      output_clob( l_chart_xml );'||unistr('\000a')||
'    END IF;'||unistr('\000a')||
'    '||unistr('\000a')||
'  END CASE;'||unistr('\000a')||
''||unistr('\000a')||
'  RETURN l_result;'||unistr('\000a')||
''||unistr('\000a')||
'END;'
 ,p_render_function => 'render_custom_chart'
 ,p_ajax_function => 'ajax_custom_chart'
 ,p_standard_attributes => 'SOURCE_SQL:NO_DATA_FOUND_MESSAGE'
 ,p_sql_min_column_count => 1
 ,p_sql_max_column_count => 1
 ,p_sql_examples => 'A statement returning a VARCHAR2 / CLOB is expected, and the content should be XML.'
 ,p_substitute_attributes => true
 ,p_subscribe_plugin_settings => true
 ,p_version_identifier => '1.0'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 526134803223580749 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 526134514221575646 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'APPLICATION'
 ,p_attribute_sequence => 1
 ,p_display_sequence => 10
 ,p_prompt => 'AnyChart JS folder'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => true
 ,p_default_value => '#IMAGE_PREFIX#flashchart/anychart_6/js/'
 ,p_is_translatable => false
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 526136019385588409 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 526134514221575646 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'APPLICATION'
 ,p_attribute_sequence => 2
 ,p_display_sequence => 20
 ,p_prompt => 'AnyChart Main JS File'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => true
 ,p_default_value => 'AnyChart.js'
 ,p_is_translatable => false
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 526137408817593287 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 526134514221575646 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'APPLICATION'
 ,p_attribute_sequence => 3
 ,p_display_sequence => 30
 ,p_prompt => 'AnyChart HTML5 JS File'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => true
 ,p_default_value => 'AnyChartHTML5.js'
 ,p_is_translatable => false
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 526139530802598310 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 526134514221575646 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'APPLICATION'
 ,p_attribute_sequence => 4
 ,p_display_sequence => 40
 ,p_prompt => 'AnyChart SWF Folder'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => true
 ,p_default_value => '#IMAGE_PREFIX#flashchart/anychart_6/swf/'
 ,p_is_translatable => false
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 526140027783599778 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 526134514221575646 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'APPLICATION'
 ,p_attribute_sequence => 5
 ,p_display_sequence => 50
 ,p_prompt => 'AnyChart Main SWF File'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => true
 ,p_default_value => 'OracleAnyChart.swf'
 ,p_is_translatable => false
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 526141024333601340 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 526134514221575646 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'APPLICATION'
 ,p_attribute_sequence => 6
 ,p_display_sequence => 60
 ,p_prompt => 'AnyChart Preload SWF File'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => true
 ,p_default_value => 'Preloader.swf'
 ,p_is_translatable => false
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 526141520882602981 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 526134514221575646 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'APPLICATION'
 ,p_attribute_sequence => 7
 ,p_display_sequence => 70
 ,p_prompt => 'AnyGantt JS Folder'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => true
 ,p_default_value => '#IMAGE_PREFIX#flashchart/anygantt_4/js/'
 ,p_is_translatable => false
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 526142415922605188 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 526134514221575646 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'APPLICATION'
 ,p_attribute_sequence => 8
 ,p_display_sequence => 80
 ,p_prompt => 'AnyGantt JS File'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => true
 ,p_default_value => 'AnyGantt.js'
 ,p_is_translatable => false
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 526142912471606881 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 526134514221575646 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'APPLICATION'
 ,p_attribute_sequence => 9
 ,p_display_sequence => 90
 ,p_prompt => 'AnyGantt SWF Folder'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => true
 ,p_default_value => '#IMAGE_PREFIX#flashchart/anygantt_4/swf/'
 ,p_is_translatable => false
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 526143409236608324 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 526134514221575646 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'APPLICATION'
 ,p_attribute_sequence => 10
 ,p_display_sequence => 100
 ,p_prompt => 'AnyGantt Main SWF File'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => true
 ,p_default_value => 'AnyGantt.swf'
 ,p_is_translatable => false
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 526144404923610290 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 526134514221575646 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'APPLICATION'
 ,p_attribute_sequence => 11
 ,p_display_sequence => 110
 ,p_prompt => 'AnyGantt Preloader SWF File'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => true
 ,p_default_value => 'Preloader.swf'
 ,p_is_translatable => false
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 526136909680592926 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 526134514221575646 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 1
 ,p_display_sequence => 10
 ,p_prompt => 'Chart Type'
 ,p_attribute_type => 'SELECT LIST'
 ,p_is_required => true
 ,p_default_value => 'CHART'
 ,p_is_translatable => false
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 526137907955593746 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 526136909680592926 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 10
 ,p_display_value => 'Chart'
 ,p_return_value => 'CHART'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 526138405798594752 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 526136909680592926 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 20
 ,p_display_value => 'Gantt'
 ,p_return_value => 'GANTT'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 526140525627600709 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 526134514221575646 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 2
 ,p_display_sequence => 20
 ,p_prompt => 'Render Type'
 ,p_attribute_type => 'SELECT LIST'
 ,p_is_required => true
 ,p_default_value => 'FLASH_PREFERRED'
 ,p_is_translatable => false
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 526141916353605000 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 526134514221575646 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 3
 ,p_display_sequence => 30
 ,p_prompt => 'Defaults XML'
 ,p_attribute_type => 'TEXTAREA'
 ,p_is_required => true
 ,p_is_translatable => false
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 526143908374608685 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 526134514221575646 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 4
 ,p_display_sequence => 40
 ,p_prompt => 'Gantt Type'
 ,p_attribute_type => 'SELECT LIST'
 ,p_is_required => true
 ,p_default_value => 'PROJECT'
 ,p_is_translatable => false
 ,p_depending_on_attribute_id => 526136909680592926 + wwv_flow_api.g_id_offset
 ,p_depending_on_condition_type => 'EQUALS'
 ,p_depending_on_expression => 'GANTT'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 526144904923610311 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 526143908374608685 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 10
 ,p_display_value => 'Project'
 ,p_return_value => 'PROJECT'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 526145402982611227 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 526143908374608685 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 20
 ,p_display_value => 'Resource'
 ,p_return_value => 'RESOURCE'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 526145821948617647 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 526134514221575646 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 5
 ,p_display_sequence => 50
 ,p_prompt => 'Height'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => false
 ,p_default_value => '400'
 ,p_is_translatable => false
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 526146319144618911 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 526134514221575646 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 6
 ,p_display_sequence => 60
 ,p_prompt => 'Width'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => false
 ,p_default_value => '700'
 ,p_is_translatable => false
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 526174107478772082 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 526134514221575646 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 7
 ,p_display_sequence => 70
 ,p_prompt => 'Event Handlers'
 ,p_attribute_type => 'TEXTAREA'
 ,p_is_required => false
 ,p_is_translatable => false
 ,p_help_text => 'Declare an object which will be passed in to the chart initialization '
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 46174400441755152 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 526134514221575646 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 8
 ,p_display_sequence => 31
 ,p_prompt => 'Defaults XML Part 2'
 ,p_attribute_type => 'TEXTAREA'
 ,p_is_required => false
 ,p_is_translatable => false
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 46175131699755924 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 526134514221575646 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 9
 ,p_display_sequence => 32
 ,p_prompt => 'Defaults XML Part 3'
 ,p_attribute_type => 'TEXTAREA'
 ,p_is_required => false
 ,p_is_translatable => false
  );
null;
 
end;
/

 
begin
 
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A0A2A20546865204D4954204C6963656E736520284D4954290A2A200A2A20436F7079726967687420286329203230313520546F6D205065747275730A2A200A2A205065726D697373696F6E20697320686572656279206772616E7465642C20667265';
wwv_flow_api.g_varchar2_table(2) := '65206F66206368617267652C20746F20616E7920706572736F6E206F627461696E696E67206120636F70790A2A206F66207468697320736F66747761726520616E64206173736F63696174656420646F63756D656E746174696F6E2066696C6573202874';
wwv_flow_api.g_varchar2_table(3) := '68652022536F66747761726522292C20746F206465616C0A2A20696E2074686520536F66747761726520776974686F7574207265737472696374696F6E2C20696E636C7564696E6720776974686F7574206C696D69746174696F6E207468652072696768';
wwv_flow_api.g_varchar2_table(4) := '74730A2A20746F207573652C20636F70792C206D6F646966792C206D657267652C207075626C6973682C20646973747269627574652C207375626C6963656E73652C20616E642F6F722073656C6C0A2A20636F70696573206F662074686520536F667477';
wwv_flow_api.g_varchar2_table(5) := '6172652C20616E6420746F207065726D697420706572736F6E7320746F2077686F6D2074686520536F6674776172652069730A2A206675726E697368656420746F20646F20736F2C207375626A65637420746F2074686520666F6C6C6F77696E6720636F';
wwv_flow_api.g_varchar2_table(6) := '6E646974696F6E733A0A2A200A2A205468652061626F766520636F70797269676874206E6F7469636520616E642074686973207065726D697373696F6E206E6F74696365207368616C6C20626520696E636C7564656420696E0A2A20616C6C20636F7069';
wwv_flow_api.g_varchar2_table(7) := '6573206F72207375627374616E7469616C20706F7274696F6E73206F662074686520536F6674776172652E0A2A200A2A2054484520534F4654574152452049532050524F564944454420224153204953222C20574954484F55542057415252414E545920';
wwv_flow_api.g_varchar2_table(8) := '4F4620414E59204B494E442C2045585052455353204F520A2A20494D504C4945442C20494E434C5544494E4720425554204E4F54204C494D4954454420544F205448452057415252414E54494553204F46204D45524348414E544142494C4954592C0A2A';
wwv_flow_api.g_varchar2_table(9) := '204649544E45535320464F52204120504152544943554C415220505552504F534520414E44204E4F4E494E4652494E47454D454E542E20494E204E4F204556454E54205348414C4C205448450A2A20415554484F5253204F5220434F5059524947485420';
wwv_flow_api.g_varchar2_table(10) := '484F4C44455253204245204C4941424C4520464F5220414E5920434C41494D2C2044414D41474553204F52204F544845520A2A204C494142494C4954592C205748455448455220494E20414E20414354494F4E204F4620434F4E54524143542C20544F52';
wwv_flow_api.g_varchar2_table(11) := '54204F52204F54484552574953452C2041524953494E472046524F4D2C0A2A204F5554204F46204F5220494E20434F4E4E454354494F4E20574954482054484520534F465457415245204F522054484520555345204F52204F54484552204445414C494E';
wwv_flow_api.g_varchar2_table(12) := '475320494E0A2A2054484520534F4654574152452E0A2A2F0A2866756E6374696F6E2861706578297B0A6966202820617065782E637573746F6D203D3D3D20756E646566696E65642029207B0A2020617065782E637573746F6D203D207B7D3B0A7D3B0A';
wwv_flow_api.g_varchar2_table(13) := '7D292861706578293B0A0A2F2A2A2040617574686F7220546F6D205065747275730A202A2020406D6F64756C6520617065782E637573746F6D2E63686172740A202A202040746F646F2077696C6C206E6F7420776F726B20776974682064617368626F61';
wwv_flow_api.g_varchar2_table(14) := '726420786D6C21210A202A202040746F646F20636861727420696420706172616D657465722C2064656661756C7420746F20726567696F6E2069643F0A202A202040746F646F206E6F206461746120666F756E64206D6573736167653F202D2062656C6F';
wwv_flow_api.g_varchar2_table(15) := '6E677320696E20584D4C3F0A202A202040746F646F206170657872656672657368206576656E74206F6E2061637475616C20726567696F6E2C206E6F74206F6E20637573746F6D206964202863635F2B726567696F6E6964290A202A2F0A2866756E6374';
wwv_flow_api.g_varchar2_table(16) := '696F6E28706172656E742C20242C20756E646566696E6564297B0A202069662028706172656E742E6368617274203D3D3D20756E646566696E656429207B0A20202020706172656E742E6368617274203D2066756E6374696F6E28297B0A202020200A20';
wwv_flow_api.g_varchar2_table(17) := '20202020202F2F20706F6C7966696C6C204945380A2020202020207661722073657269616C697A65586D6C4E6F6465203D2066756E6374696F6E2028786D6C4E6F646529207B0A2020202020202020202069662028747970656F662077696E646F772E58';
wwv_flow_api.g_varchar2_table(18) := '4D4C53657269616C697A657220213D2022756E646566696E65642229207B0A202020202020202020202020202072657475726E20286E65772077696E646F772E584D4C53657269616C697A65722829292E73657269616C697A65546F537472696E672878';
wwv_flow_api.g_varchar2_table(19) := '6D6C4E6F6465293B0A202020202020202020207D20656C73652069662028747970656F6620786D6C4E6F64652E786D6C20213D2022756E646566696E65642229207B0A202020202020202020202020202072657475726E20786D6C4E6F64652E786D6C3B';
wwv_flow_api.g_varchar2_table(20) := '0A202020202020202020207D0A2020202020202020202072657475726E2022223B0A2020202020207D3B0A2020202020200A2020202020202F2A2A0A2020202020202A2040746F646F206B65657020616E206172726179206F6620696E697469616C697A';
wwv_flow_api.g_varchar2_table(21) := '65642063686172747320666F722065617379206163636573732E20457370656369616C6C7920666F722048544D4C35206368617274730A2020202020202A206B65792F76616C75652070616972732077697468204944202F206368617274206F626A6563';
wwv_flow_api.g_varchar2_table(22) := '740A2020202020202A2F0A2020202020207661722067416C6C436861727473203D205B5D3B0A2020202020200A2020202020202F2A2A0A202020202020202A2040706172616D207054617267657453656C6563746F720A202020202020202A2040706172';
wwv_flow_api.g_varchar2_table(23) := '616D20704F7074696F6E7320616E206F626A65637420776974682070726F7065727469657320746F20646566696E65207468652063686172740A202020202020202A2040706172616D20704F7074696F6E732E74797065203A204348415254206F722047';
wwv_flow_api.g_varchar2_table(24) := '414E54540A202020202020202A2040706172616D20704F7074696F6E732E72656E64657274797065203A2068746D6C206F7220666C6173680A202020202020202A2040706172616D20704F7074696F6E732E73776646696C65203A206C6F636174696F6E';
wwv_flow_api.g_varchar2_table(25) := '206F6620746865207377662066696C6520666F72207468652063686172740A202020202020202A2040706172616D20704F7074696F6E732E7072656C6F6164657246696C65203A206C6F636174696F6E206F6620746865207377662066696C6520757365';
wwv_flow_api.g_varchar2_table(26) := '6420666F72207072656C6F616420696E6469636174696F6E0A202020202020202A2040706172616D20704F7074696F6E732E7769647468203A207769647468206F66207468652063686172740A202020202020202A2040706172616D20704F7074696F6E';
wwv_flow_api.g_varchar2_table(27) := '732E686569676874203A20686569676874206F66207468652063686172740A202020202020202A2040706172616D20704F7074696F6E732E616A617850726F636573734E616D65203A206E616D65206F66207468652041504558206F6E2D64656D616E64';
wwv_flow_api.g_varchar2_table(28) := '2070726F6365737320746F2063616C6C20696E206F7264657220746F20726574726965766520646174612E204F4E4C592064617461206973206578706563746564206261636B2C20616E64206F6E6C79207468652070726F6A656374206F72207265736F';
wwv_flow_api.g_varchar2_table(29) := '75726365206368617274206E6F64652077696C6C2062652070726F6365737365642E0A202020202020202A2040706172616D20704F7074696F6E732E616A617820616E206F626A65637420776974682070726F70657274696573206F6E20686F7720746F';
wwv_flow_api.g_varchar2_table(30) := '207265747269657665206461746120616E642064656661756C74730A202020202020202A2040706172616D20704F7074696F6E732E616A61782E64617461207B537472696E677C4F626A6563747D2045697468657220746865206E616D65206F66207468';
wwv_flow_api.g_varchar2_table(31) := '652041504558206F6E2D64656D616E642070726F6365737320746F2063616C6C20696E206F7264657220746F20726574726965766520646174612C206F7220616E206F626A65637420776974682073657474696E677320746F2070617373206F6E20746F';
wwv_flow_api.g_varchar2_table(32) := '20242E616A617828292028224120736574206F66206B65792F76616C7565207061697273207468617420636F6E6669677572652074686520416A617820726571756573742E22292E20456974686572207761792C20746865206578706563746564206461';
wwv_flow_api.g_varchar2_table(33) := '7461207479706520697320584D4C20210A202020202020202A202A2A2A2A2A2A2A2A2A2A2A2A28284F4E4C592064617461206973206578706563746564206261636B2C20616E64206F6E6C79207468652070726F6A656374206F72207265736F75726365';
wwv_flow_api.g_varchar2_table(34) := '206368617274206E6F64652077696C6C2062652070726F6365737365642E29290A2020202020202040706172616D20704F7074696F6E732E616A61782E64656661756C7473207B537472696E677C4F626A6563747D2045697468657220746865206E616D';
wwv_flow_api.g_varchar2_table(35) := '65206F66207468652041504558206F6E2D64656D616E642070726F6365737320746F2063616C6C20696E206F7264657220746F2072657472696576652064656661756C74732C206F7220616E206F626A65637420776974682073657474696E677320746F';
wwv_flow_api.g_varchar2_table(36) := '2070617373206F6E20746F20242E616A617828292028224120736574206F66206B65792F76616C7565207061697273207468617420636F6E6669677572652074686520416A617820726571756573742E22292E20456974686572207761792C2074686520';
wwv_flow_api.g_varchar2_table(37) := '65787065637465642064617461207479706520697320584D4C20210A202020202020202A2040706172616D20704F7074696F6E732E64656661756C74734C6F636174696F6E203A20776865726520746F20726574726965766520616E20786D6C20776974';
wwv_flow_api.g_varchar2_table(38) := '68207468652064656661756C742073657474696E6773206F66207468652063686172742E205468697320786D6C2077696C6C2062652066657463686564206F6E6C79206F6E63652C2069742077696C6C206E6F742062652066657463686564207768656E';
wwv_flow_api.g_varchar2_table(39) := '2074686520726567696F6E206973207265667265736865642E0A202020202020202A2040706172616D20704F7074696F6E732E636861727454797065203A2043484152543A20646174612C2047414E54543A2070726F6A6563745F63686172747C726573';
wwv_flow_api.g_varchar2_table(40) := '6F757263655F63686172740A202020202020202A2040706172616D20704F7074696F6E732E6576656E7448616E646C657273207B4F626A6563747D206F626A6563742077697468206576656E742068616E646C65727320746F2062696E6420746F207468';
wwv_flow_api.g_varchar2_table(41) := '652063686172742E2055736520746865206368617274277320646F63756D656E7465642063616C6C6261636B732E205468652066756E6374696F6E277320636F6E746578742077696C6C2062652073657420746F20746865206368617274206F626A6563';
wwv_flow_api.g_varchar2_table(42) := '740A202020202020202A204072657475726E20416E794368617274206F626A6563740A202020202020202A20406578616D706C65200A202020202020202A20617065782E637573746F6D2E63686172742E61646428242822236D7943686172743122292C';
wwv_flow_api.g_varchar2_table(43) := '200A202020202020202A2020202020202020202020202020202020207B2274797065223A224348415254220A202020202020202A2020202020202020202020202020202020202C2272656E64657274797065223A22464C4153485F505245464552524544';
wwv_flow_api.g_varchar2_table(44) := '220A202020202020202A2020202020202020202020202020202020202C2273776646696C65223A20617065785F696D675F646972202B2022666C61736863686172742F616E7967616E74745F342F7377662F416E7947616E74742E737766220A20202020';
wwv_flow_api.g_varchar2_table(45) := '2020202A2020202020202020202020202020202020202C227072656C6F6164657246696C65223A20617065785F696D675F646972202B2022666C61736863686172742F616E7967616E74745F342F7377662F5072656C6F616465722E737766220A202020';
wwv_flow_api.g_varchar2_table(46) := '202020202A2020202020202020202020202020202020202C227769647468223A2231323030220A202020202020202A2020202020202020202020202020202020202C22686569676874223A22383030220A202020202020202A2020202020202020202020';
wwv_flow_api.g_varchar2_table(47) := '202020202020202C22616A6178223A7B2264617461223A2247414E54545F50524F4A4543545F44415441222C202264656661756C7473223A2247414E54545F44454641554C5453227D0A202020202020202A202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(48) := '2C22636861727454797065223A2270726F6A6563745F6368617274220A202020202020202A2020202020202020202020202020202020202C226576656E7448616E646C657273223A7B227461736B53656C656374223A66756E6374696F6E2865297B2063';
wwv_flow_api.g_varchar2_table(49) := '6F6E736F6C652E6C6F672820746869732E6765745461736B496E666F28652E69642920293B207D7D0A202020202020202A2020202020202020202020202020202020207D0A202020202020202A2020202020202020202020202020202020293B0A202020';
wwv_flow_api.g_varchar2_table(50) := '202020202A2A2F0A20202020202076617220616464203D2066756E6374696F6E287054617267657453656C6563746F722C20704F7074696F6E73297B0A2020202020202020766172206C43686172742C206C44656661756C74732C206C54617267657424';
wwv_flow_api.g_varchar2_table(51) := '203D2024287054617267657453656C6563746F72293B0A20202020202020200A2020202020202020617065782E64656275672822696E697469616C6973696E6720636861727422293B0A20202020202020200A20202020202020206966202820704F7074';
wwv_flow_api.g_varchar2_table(52) := '696F6E732E73776646696C6520262620704F7074696F6E732E74797065203D3D3D202247414E54542229207B0A2020202020202020202020206C4368617274203D206E657720416E7947616E74742820704F7074696F6E732E73776646696C652C20704F';
wwv_flow_api.g_varchar2_table(53) := '7074696F6E732E7072656C6F6164657246696C6520293B0A20202020202020207D20656C7365207B0A202020202020202020202020416E7943686172742E75736542726F77736572526573697A65203D20747275653B0A0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(54) := '6966202820704F7074696F6E732E72656E64657274797065203D3D3D2022464C4153485F505245464552524544222029207B20202F2A2A2040746F646F3A20657870616E64202A2F0A20202020202020202020202020202020416E7943686172742E7265';
wwv_flow_api.g_varchar2_table(55) := '6E646572696E6754797065203D20616E7963686172742E52656E646572696E67547970652E464C4153485F5052454645525245443B0A202020202020202020202020202020206C4368617274203D206E657720416E7943686172742820704F7074696F6E';
wwv_flow_api.g_varchar2_table(56) := '732E73776646696C652C20704F7074696F6E732E7072656C6F6164657246696C6520293B0A2020202020202020202020207D20656C7365207B0A20202020202020202020202020202020416E7943686172742E72656E646572696E6754797065203D2061';
wwv_flow_api.g_varchar2_table(57) := '6E7963686172742E52656E646572696E67547970652E5356475F4F4E4C593B0A202020202020202020202020202020206C4368617274203D206E657720416E79436861727428293B0A2020202020202020202020207D0A20202020202020207D3B0A2020';
wwv_flow_api.g_varchar2_table(58) := '2020202020200A20202020202020206C43686172742E774D6F646520203D20227472616E73706172656E74223B0A0A202020202020202069662028704F7074696F6E732E686569676874203D3D3D20223939252229207B0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(59) := '6C43686172742E686569676874203D2024282077696E646F7720292E6865696768742829202D203130303B0A20202020202020207D20656C7365207B0A2020202020202020202020206C43686172742E686569676874203D20704F7074696F6E732E6865';
wwv_flow_api.g_varchar2_table(60) := '696768743B0A20202020202020207D3B0A202020202020202069662028704F7074696F6E732E7769647468203D3D3D2022313030252229207B0A2020202020202020202020206C43686172742E7769647468203D20704F7074696F6E732E77696474683B';
wwv_flow_api.g_varchar2_table(61) := '202F2F646F6E74206B6E6F77207768792061706578206C696220686173203120686572653F0A20202020202020207D20656C7365207B0A2020202020202020202020206C43686172742E7769647468203D20704F7074696F6E732E77696474683B0A2020';
wwv_flow_api.g_varchar2_table(62) := '2020202020207D3B0A20202020202020200A20202020202020202F2F20696620746865207461736B53656C656374206F7074696F6E20697320612066756E6374696F6E2C2062696E6420697420616E642070726F7669646520746865207461736B206173';
wwv_flow_api.g_varchar2_table(63) := '206120706172616D657465720A20202020202020202F2F206F746865727769736520646F206E6F7468696E670A20202020202020202F2A69662820704F7074696F6E732E74797065203D3D3D202247414E54542220262620242E697346756E6374696F6E';
wwv_flow_api.g_varchar2_table(64) := '28704F7074696F6E732E7461736B53656C6563742920297B0A20202020202020202020766172206F6E5461736B53656C656374203D2066756E6374696F6E20286529207B20202020202020202020202020200A2020202020202020202020202020766172';
wwv_flow_api.g_varchar2_table(65) := '207461736B203D206C43686172742E6765745461736B496E666F28652E6964293B0A2020202020202020202020202020704F7074696F6E732E7461736B53656C6563742E63616C6C286E756C6C2C207461736B293B0A202020202020202020207D3B0A20';
wwv_flow_api.g_varchar2_table(66) := '202020202020200A202020202020202020206C43686172742E6164644576656E744C697374656E657228277461736B53656C656374272C6F6E5461736B53656C656374293B0A20202020202020207D3B2A2F0A20202020202020200A2020202020202020';
wwv_flow_api.g_varchar2_table(67) := '6966202820242E7479706528704F7074696F6E732E6576656E7448616E646C65727329203D3D3D20226F626A656374222029207B0A202020202020202020204F626A6563742E6B65797328704F7074696F6E732E6576656E7448616E646C657273292E66';
wwv_flow_api.g_varchar2_table(68) := '6F72456163682866756E6374696F6E286B6579297B0A2020202020202020202020206C43686172742E6164644576656E744C697374656E6572286B65792C20242E70726F78792820704F7074696F6E732E6576656E7448616E646C6572735B6B65795D2C';
wwv_flow_api.g_varchar2_table(69) := '206C43686172742920293B0A202020202020202020207D293B0A20202020202020207D3B0A20202020202020200A20202020202020202F2F207365742075702074686520726566726573682066756E6374696F6E0A2020202020202020766172205F7265';
wwv_flow_api.g_varchar2_table(70) := '6672657368203D2066756E6374696F6E287044656661756C7473297B0A20202020202020202020766172206C4461746150726F6D6973653B0A20202020202020202020617065782E646562756728226C43686172742022293B0A20202020202020202020';
wwv_flow_api.g_varchar2_table(71) := '617065782E6465627567286C4368617274293B0A202020202020202020202F2F6C43686172742E7365744C6F6164696E67282222293B0A202020202020202020200A20202020202020202020617065782E64656275672822726566726573682063686172';
wwv_flow_api.g_varchar2_table(72) := '7422293B0A202020202020202020206C546172676574242E747269676765722822617065786265666F72657265667265736822293B0A0A202020202020202020206966202820242E7479706528704F7074696F6E732E616A617829203D3D3D20226F626A';
wwv_flow_api.g_varchar2_table(73) := '6563742220262620242E7479706528704F7074696F6E732E616A61782E6461746129203D3D3D2022737472696E672220297B0A2020202020202020202020206C4461746150726F6D697365203D20617065782E7365727665722E70726F6365737328704F';
wwv_flow_api.g_varchar2_table(74) := '7074696F6E732E616A61782E646174612C7B7D2C7B64617461547970653A2022786D6C227D293B0A202020202020202020207D20656C7365206966202820242E7479706528704F7074696F6E732E616A617829203D3D3D20226F626A6563742220262620';
wwv_flow_api.g_varchar2_table(75) := '242E7479706528704F7074696F6E732E616A61782E6461746129203D3D3D20226F626A656374222029207B0A2020202020202020202020206C4461746150726F6D697365203D20242E616A617828704F7074696F6E732E616A61782E64617461293B0A20';
wwv_flow_api.g_varchar2_table(76) := '2020202020202020207D3B0A202020202020202020200A202020202020202020206C4461746150726F6D6973652E646F6E652866756E6374696F6E287044617461297B0A202020202020202020202020617065782E646562756728276368617274747970';
wwv_flow_api.g_varchar2_table(77) := '653A2027202B20704F7074696F6E732E636861727454797065293B0A2020202020202020202020202F2F2066696E64207468652070726F6A6563745F6368617274206F72207265736F757263655F6368617274206E6F646520696E207468652072657475';
wwv_flow_api.g_varchar2_table(78) := '726E656420646174610A202020202020202020202020766172206C4E6577203D2024287044617461292E66696E6428704F7074696F6E732E636861727454797065293B0A202020202020202020202020617065782E6465627567286C4E6577293B0A2020';
wwv_flow_api.g_varchar2_table(79) := '202020202020202020202F2F2066696E642074686520785F6368617274206E6F646520696E207468652064656661756C74730A202020202020202020202020766172206C4F6C64203D2024287044656661756C7473292E66696E6428704F7074696F6E73';
wwv_flow_api.g_varchar2_table(80) := '2E636861727454797065293B0A202020202020202020202020617065782E6465627567286C4F6C64293B0A2020202020202020202020202F2F207265706C6163652074686520785F6368617274206E6F646520696E207468652064656661756C74732077';
wwv_flow_api.g_varchar2_table(81) := '697468207468652070617373656420646174610A2020202020202020202020202F2F207468697320616C74657273207044656661756C747321200A2020202020202020202020202F2A2A2040746F646F207044656661756C74732073686F756C64206E6F';
wwv_flow_api.g_varchar2_table(82) := '742067657420616C7465726564202A2F0A2020202020202020202020206C4F6C642E7265706C61636557697468286C4E6577293B2020202020202020202020200A2020202020202020202020202F2F2073657269616C697A652074686520786D6C0A2020';
wwv_flow_api.g_varchar2_table(83) := '2020202020202020202076617220786D6C74657874203D2073657269616C697A65586D6C4E6F6465287044656661756C7473293B0A202020202020202020202020617065782E646562756728786D6C74657874293B0A2020202020202020202020202F2F';
wwv_flow_api.g_varchar2_table(84) := '207061737320697420746F20616E7963686172740A2020202020202020202020206C43686172742E7365744461746128786D6C74657874293B0A2020202020202020202020206C546172676574242E747269676765722822617065786166746572726566';
wwv_flow_api.g_varchar2_table(85) := '7265736822293B0A202020202020202020202020617065782E64656275672822656E64207265667265736820636861727422293B0A202020202020202020207D293B0A20202020202020207D3B0A20202020202020200A20202020202020202F2F207661';
wwv_flow_api.g_varchar2_table(86) := '6E726F7468206D6F7665640A20202020202020206C43686172742E777269746528206C546172676574245B305D20293B0A20202020202020202F2F207265747269657665207468652064656661756C74732E204E6F746520746861742074686520646566';
wwv_flow_api.g_varchar2_table(87) := '61756C74734C6F636174696F6E20706172616D20636F756C6420626520612075726C206574632C20697420646F65736E2774206861766520746F20626520612066696C65206C6F636174696F6E0A20202020202020202F2F20544F444F3A206D616B6520';
wwv_flow_api.g_varchar2_table(88) := '7468697320612066756E6374696F6E2063616C6C6261636B0A2020202020202020766172206C44656661756C747350726F6D6973653B0A20202020202020206966202820242E7479706528704F7074696F6E732E616A61782E64656661756C747329203D';
wwv_flow_api.g_varchar2_table(89) := '3D3D2022737472696E672220297B0A202020202020202020206C44656661756C747350726F6D697365203D20617065782E7365727665722E70726F6365737328704F7074696F6E732E616A61782E64656661756C74732C7B7D2C7B64617461547970653A';
wwv_flow_api.g_varchar2_table(90) := '2022786D6C227D293B0A20202020202020207D20656C7365206966202820242E7479706528704F7074696F6E732E616A61782E64656661756C747329203D3D3D20226F626A6563742220262620242E7479706528704F7074696F6E732E616A61782E6465';
wwv_flow_api.g_varchar2_table(91) := '6661756C747329203D3D3D20226F626A656374222029207B0A202020202020202020206C44656661756C747350726F6D697365203D20242E616A617828704F7074696F6E732E616A61782E64656661756C7473293B0A20202020202020207D3B0A202020';
wwv_flow_api.g_varchar2_table(92) := '20202020200A20202020202020206C44656661756C747350726F6D6973652E646F6E652866756E6374696F6E287044656661756C7473297B0A202020202020202020206C44656661756C7473203D207044656661756C74733B0A20202020202020202020';
wwv_flow_api.g_varchar2_table(93) := '617065782E6465627567282264656661756C747320666574636865643A2022293B0A20202020202020202020617065782E6465627567286C44656661756C7473293B0A202020202020202020202F2F2062696E6420746F20746865206170657872656672';
wwv_flow_api.g_varchar2_table(94) := '657368206576656E7420616E6420636C6F73757265207468652064656661756C74730A202020202020202020206C546172676574242E6F6E28226170657872656672657368222C2066756E6374696F6E28297B205F72656672657368286C44656661756C';
wwv_flow_api.g_varchar2_table(95) := '7473293B207D292E747269676765722822617065787265667265736822293B0A20202020202020207D293B0A20202020202020200A202020202020202067416C6C4368617274732E70757368287B226964223A6C546172676574242E6174747228226964';
wwv_flow_api.g_varchar2_table(96) := '22292C2263686172744F626A656374223A6C43686172747D293B0A20202020202020200A202020202020202072657475726E206C43686172743B0A2020202020207D3B0A2020202020200A202020202020766172206765744368617274203D2066756E63';
wwv_flow_api.g_varchar2_table(97) := '74696F6E2028207049642029207B0A202020202020202072657475726E2067416C6C4368617274732E66696C7465722866756E6374696F6E286F626A297B0A2020202020202020202072657475726E206F626A2E6964203D3D3D207049643B0A20202020';
wwv_flow_api.g_varchar2_table(98) := '202020207D295B305D3B0A2020202020207D3B0A2020202020200A2020202020202F2F206578706F7365207075626C69636C790A20202020202072657475726E207B20616464203A206164640A202020202020202020202020202C206765744368617274';
wwv_flow_api.g_varchar2_table(99) := '203A2067657443686172740A202020202020202020202020207D203B0A202020207D28293B0A20207D3B0A7D2928617065782E637573746F6D2C206A5175657279293B';
null;
 
end;
/

 
begin
 
wwv_flow_api.create_plugin_file (
  p_id => 40156622524190443 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 526134514221575646 + wwv_flow_api.g_id_offset
 ,p_file_name => 'apex.custom.chart.js'
 ,p_mime_type => 'application/javascript'
 ,p_file_content => wwv_flow_api.g_varchar2_table
  );
null;
 
end;
/

 
begin
 
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2166756E6374696F6E2865297B766F696420303D3D3D652E637573746F6D262628652E637573746F6D3D7B7D297D2861706578292C66756E6374696F6E28652C612C74297B652E63686172743D3D3D74262628652E63686172743D66756E6374696F6E28';
wwv_flow_api.g_varchar2_table(2) := '297B76617220653D66756E6374696F6E2865297B72657475726E22756E646566696E656422213D747970656F662077696E646F772E584D4C53657269616C697A65723F286E65772077696E646F772E584D4C53657269616C697A6572292E73657269616C';
wwv_flow_api.g_varchar2_table(3) := '697A65546F537472696E672865293A22756E646566696E656422213D747970656F6620652E786D6C3F652E786D6C3A22227D2C743D5B5D2C723D66756E6374696F6E28722C6E297B76617220692C642C703D612872293B617065782E6465627567282269';
wwv_flow_api.g_varchar2_table(4) := '6E697469616C6973696E6720636861727422292C6E2E73776646696C6526262247414E5454223D3D3D6E2E747970653F693D6E657720416E7947616E7474286E2E73776646696C652C6E2E7072656C6F6164657246696C65293A28416E7943686172742E';
wwv_flow_api.g_varchar2_table(5) := '75736542726F77736572526573697A653D21302C22464C4153485F505245464552524544223D3D3D6E2E72656E646572747970653F28416E7943686172742E72656E646572696E67547970653D616E7963686172742E52656E646572696E67547970652E';
wwv_flow_api.g_varchar2_table(6) := '464C4153485F5052454645525245442C693D6E657720416E794368617274286E2E73776646696C652C6E2E7072656C6F6164657246696C6529293A28416E7943686172742E72656E646572696E67547970653D616E7963686172742E52656E646572696E';
wwv_flow_api.g_varchar2_table(7) := '67547970652E5356475F4F4E4C592C693D6E657720416E79436861727429292C692E774D6F64653D227472616E73706172656E74222C692E6865696768743D22393925223D3D3D6E2E6865696768743F612877696E646F77292E68656967687428292D31';
wwv_flow_api.g_varchar2_table(8) := '30303A6E2E6865696768742C692E77696474683D2231303025223D3D3D6E2E77696474683F6E2E77696474683A6E2E77696474682C226F626A656374223D3D3D612E74797065286E2E6576656E7448616E646C6572732926264F626A6563742E6B657973';
wwv_flow_api.g_varchar2_table(9) := '286E2E6576656E7448616E646C657273292E666F72456163682866756E6374696F6E2865297B692E6164644576656E744C697374656E657228652C612E70726F7879286E2E6576656E7448616E646C6572735B655D2C6929297D293B76617220753D6675';
wwv_flow_api.g_varchar2_table(10) := '6E6374696F6E2874297B76617220723B617065782E646562756728226C436861727422292C617065782E64656275672869292C617065782E646562756728227265667265736820636861727422292C702E747269676765722822617065786265666F7265';
wwv_flow_api.g_varchar2_table(11) := '7265667265736822292C226F626A656374223D3D3D612E74797065286E2E616A617829262622737472696E67223D3D3D612E74797065286E2E616A61782E64617461293F723D617065782E7365727665722E70726F63657373286E2E616A61782E646174';
wwv_flow_api.g_varchar2_table(12) := '612C7B7D2C7B64617461547970653A22786D6C227D293A226F626A656374223D3D3D612E74797065286E2E616A6178292626226F626A656374223D3D3D612E74797065286E2E616A61782E6461746129262628723D612E616A6178286E2E616A61782E64';
wwv_flow_api.g_varchar2_table(13) := '61746129292C722E646F6E652866756E6374696F6E2872297B617065782E646562756728226368617274747970653A20222B6E2E636861727454797065293B76617220643D612872292E66696E64286E2E636861727454797065293B617065782E646562';
wwv_flow_api.g_varchar2_table(14) := '75672864293B76617220753D612874292E66696E64286E2E636861727454797065293B617065782E64656275672875292C752E7265706C616365576974682864293B76617220683D652874293B617065782E64656275672868292C692E73657444617461';
wwv_flow_api.g_varchar2_table(15) := '2868292C702E7472696767657228226170657861667465727265667265736822292C617065782E64656275672822656E64207265667265736820636861727422297D297D3B692E777269746528705B305D293B76617220683B72657475726E2273747269';
wwv_flow_api.g_varchar2_table(16) := '6E67223D3D3D612E74797065286E2E616A61782E64656661756C7473293F683D617065782E7365727665722E70726F63657373286E2E616A61782E64656661756C74732C7B7D2C7B64617461547970653A22786D6C227D293A226F626A656374223D3D3D';
wwv_flow_api.g_varchar2_table(17) := '612E74797065286E2E616A61782E64656661756C7473292626226F626A656374223D3D3D612E74797065286E2E616A61782E64656661756C747329262628683D612E616A6178286E2E616A61782E64656661756C747329292C682E646F6E652866756E63';
wwv_flow_api.g_varchar2_table(18) := '74696F6E2865297B643D652C617065782E6465627567282264656661756C747320666574636865643A2022292C617065782E64656275672864292C702E6F6E28226170657872656672657368222C66756E6374696F6E28297B752864297D292E74726967';
wwv_flow_api.g_varchar2_table(19) := '6765722822617065787265667265736822297D292C742E70757368287B69643A702E617474722822696422292C63686172744F626A6563743A697D292C697D2C6E3D66756E6374696F6E2865297B72657475726E20742E66696C7465722866756E637469';
wwv_flow_api.g_varchar2_table(20) := '6F6E2861297B72657475726E20612E69643D3D3D657D295B305D7D3B72657475726E7B6164643A722C67657443686172743A6E7D7D2829297D28617065782E637573746F6D2C6A5175657279293B';
null;
 
end;
/

 
begin
 
wwv_flow_api.create_plugin_file (
  p_id => 40160102492326746 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 526134514221575646 + wwv_flow_api.g_id_offset
 ,p_file_name => 'apex.custom.chart.min.js'
 ,p_mime_type => 'application/javascript'
 ,p_file_content => wwv_flow_api.g_varchar2_table
  );
null;
 
end;
/

commit;
begin
execute immediate 'begin sys.dbms_session.set_nls( param => ''NLS_NUMERIC_CHARACTERS'', value => '''''''' || replace(wwv_flow_api.g_nls_numeric_chars,'''''''','''''''''''') || ''''''''); end;';
end;
/
set verify on
set feedback on
set define on
prompt  ...done
