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
  wwv_flow_api.set_security_group_id(p_security_group_id=>nvl(wwv_flow_application_install.get_workspace_id,197700620527423412));
 
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
   wwv_flow.g_flow_id := nvl(wwv_flow_application_install.get_application_id,564);
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
  p_id => 1483751726531939169 + wwv_flow_api.g_id_offset
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
 ,p_about_url => 'https://github.com/tompetrus/oracle-apex-custom-chart'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 1483752015533944272 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 1483751726531939169 + wwv_flow_api.g_id_offset
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
  p_id => 1483753231695951932 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 1483751726531939169 + wwv_flow_api.g_id_offset
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
  p_id => 1483754621127956810 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 1483751726531939169 + wwv_flow_api.g_id_offset
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
  p_id => 1483756743112961833 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 1483751726531939169 + wwv_flow_api.g_id_offset
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
  p_id => 1483757240093963301 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 1483751726531939169 + wwv_flow_api.g_id_offset
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
  p_id => 1483758236643964863 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 1483751726531939169 + wwv_flow_api.g_id_offset
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
  p_id => 1483758733192966504 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 1483751726531939169 + wwv_flow_api.g_id_offset
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
  p_id => 1483759628232968711 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 1483751726531939169 + wwv_flow_api.g_id_offset
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
  p_id => 1483760124781970404 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 1483751726531939169 + wwv_flow_api.g_id_offset
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
  p_id => 1483760621546971847 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 1483751726531939169 + wwv_flow_api.g_id_offset
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
  p_id => 1483761617233973813 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 1483751726531939169 + wwv_flow_api.g_id_offset
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
  p_id => 1483754121990956449 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 1483751726531939169 + wwv_flow_api.g_id_offset
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
  p_id => 1483755120265957269 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 1483754121990956449 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 10
 ,p_display_value => 'Chart'
 ,p_return_value => 'CHART'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 1483755618108958275 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 1483754121990956449 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 20
 ,p_display_value => 'Gantt'
 ,p_return_value => 'GANTT'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 1483757737937964232 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 1483751726531939169 + wwv_flow_api.g_id_offset
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
  p_id => 1483759128663968523 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 1483751726531939169 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 3
 ,p_display_sequence => 30
 ,p_prompt => 'Defaults XML'
 ,p_attribute_type => 'TEXTAREA'
 ,p_is_required => true
 ,p_is_translatable => false
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 1483761120684972208 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 1483751726531939169 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 4
 ,p_display_sequence => 40
 ,p_prompt => 'Gantt Type'
 ,p_attribute_type => 'SELECT LIST'
 ,p_is_required => true
 ,p_default_value => 'PROJECT'
 ,p_is_translatable => false
 ,p_depending_on_attribute_id => 1483754121990956449 + wwv_flow_api.g_id_offset
 ,p_depending_on_condition_type => 'EQUALS'
 ,p_depending_on_expression => 'GANTT'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 1483762117233973834 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 1483761120684972208 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 10
 ,p_display_value => 'Project'
 ,p_return_value => 'PROJECT'
  );
wwv_flow_api.create_plugin_attr_value (
  p_id => 1483762615292974750 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_attribute_id => 1483761120684972208 + wwv_flow_api.g_id_offset
 ,p_display_sequence => 20
 ,p_display_value => 'Resource'
 ,p_return_value => 'RESOURCE'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 1483763034258981170 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 1483751726531939169 + wwv_flow_api.g_id_offset
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
  p_id => 1483763531454982434 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 1483751726531939169 + wwv_flow_api.g_id_offset
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
  p_id => 1483791319789135605 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 1483751726531939169 + wwv_flow_api.g_id_offset
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
  p_id => 989918438901854889 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 1483751726531939169 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 8
 ,p_display_sequence => 31
 ,p_prompt => 'Defaults XML Part 2'
 ,p_attribute_type => 'TEXTAREA'
 ,p_is_required => false
 ,p_is_translatable => false
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 989918936960855755 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 1483751726531939169 + wwv_flow_api.g_id_offset
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
wwv_flow_api.g_varchar2_table(1) := '2F2A21204D696E6966696564206F6E20323031352D30392D3235202A2F0A2166756E6374696F6E2861297B766F696420303D3D3D612E637573746F6D262628612E637573746F6D3D7B7D297D2861706578292C66756E6374696F6E28612C622C63297B61';
wwv_flow_api.g_varchar2_table(2) := '2E63686172743D3D3D63262628612E63686172743D66756E6374696F6E28297B76617220613D66756E6374696F6E2861297B72657475726E22756E646566696E656422213D747970656F662077696E646F772E584D4C53657269616C697A65723F286E65';
wwv_flow_api.g_varchar2_table(3) := '772077696E646F772E584D4C53657269616C697A6572292E73657269616C697A65546F537472696E672861293A22756E646566696E656422213D747970656F6620612E786D6C3F612E786D6C3A22227D2C633D5B5D2C643D66756E6374696F6E28642C65';
wwv_flow_api.g_varchar2_table(4) := '297B76617220662C672C683D622864293B617065782E64656275672822696E697469616C6973696E6720636861727422292C652E73776646696C6526262247414E5454223D3D3D652E747970653F663D6E657720416E7947616E747428652E7377664669';
wwv_flow_api.g_varchar2_table(5) := '6C652C652E7072656C6F6164657246696C65293A28416E7943686172742E75736542726F77736572526573697A653D21302C22464C4153485F505245464552524544223D3D3D652E72656E646572747970653F28416E7943686172742E72656E64657269';
wwv_flow_api.g_varchar2_table(6) := '6E67547970653D616E7963686172742E52656E646572696E67547970652E464C4153485F5052454645525245442C663D6E657720416E79436861727428652E73776646696C652C652E7072656C6F6164657246696C6529293A28416E7943686172742E72';
wwv_flow_api.g_varchar2_table(7) := '656E646572696E67547970653D616E7963686172742E52656E646572696E67547970652E5356475F4F4E4C592C663D6E657720416E79436861727429292C662E774D6F64653D227472616E73706172656E74222C662E6865696768743D22393925223D3D';
wwv_flow_api.g_varchar2_table(8) := '3D652E6865696768743F622877696E646F77292E68656967687428292D3130303A652E6865696768742C662E77696474683D2231303025223D3D3D652E77696474683F652E77696474683A652E77696474682C226F626A656374223D3D3D622E74797065';
wwv_flow_api.g_varchar2_table(9) := '28652E6576656E7448616E646C6572732926264F626A6563742E6B65797328652E6576656E7448616E646C657273292E666F72456163682866756E6374696F6E2861297B662E6164644576656E744C697374656E657228612C622E70726F787928652E65';
wwv_flow_api.g_varchar2_table(10) := '76656E7448616E646C6572735B615D2C6629297D293B76617220692C6A3D66756E6374696F6E2863297B76617220643B662E7365744C6F6164696E67282222292C617065782E646562756728227265667265736820636861727422292C682E7472696767';
wwv_flow_api.g_varchar2_table(11) := '65722822617065786265666F72657265667265736822292C226F626A656374223D3D3D622E7479706528652E616A617829262622737472696E67223D3D3D622E7479706528652E616A61782E64617461293F643D617065782E7365727665722E70726F63';
wwv_flow_api.g_varchar2_table(12) := '65737328652E616A61782E646174612C7B7D2C7B64617461547970653A22786D6C227D293A226F626A656374223D3D3D622E7479706528652E616A6178292626226F626A656374223D3D3D622E7479706528652E616A61782E6461746129262628643D62';
wwv_flow_api.g_varchar2_table(13) := '2E616A617828652E616A61782E6461746129292C642E646F6E652866756E6374696F6E2864297B617065782E646562756728226368617274747970653A20222B652E636861727454797065293B76617220673D622864292E66696E6428652E6368617274';
wwv_flow_api.g_varchar2_table(14) := '54797065293B617065782E64656275672867293B76617220693D622863292E66696E6428652E636861727454797065293B617065782E64656275672869292C692E7265706C616365576974682867293B766172206A3D612863293B617065782E64656275';
wwv_flow_api.g_varchar2_table(15) := '67286A292C662E73657444617461286A292C682E7472696767657228226170657861667465727265667265736822292C617065782E64656275672822656E64207265667265736820636861727422297D297D3B72657475726E22737472696E67223D3D3D';
wwv_flow_api.g_varchar2_table(16) := '622E7479706528652E616A61782E64656661756C7473293F693D617065782E7365727665722E70726F6365737328652E616A61782E64656661756C74732C7B7D2C7B64617461547970653A22786D6C227D293A226F626A656374223D3D3D622E74797065';
wwv_flow_api.g_varchar2_table(17) := '28652E616A61782E64656661756C7473292626226F626A656374223D3D3D622E7479706528652E616A61782E64656661756C747329262628693D622E616A617828652E616A61782E64656661756C747329292C692E646F6E652866756E6374696F6E2861';
wwv_flow_api.g_varchar2_table(18) := '297B673D612C617065782E6465627567282264656661756C747320666574636865643A2022292C617065782E64656275672867292C682E6F6E28226170657872656672657368222C66756E6374696F6E28297B6A2867297D292E74726967676572282261';
wwv_flow_api.g_varchar2_table(19) := '7065787265667265736822297D292C662E777269746528685B305D292C632E70757368287B69643A682E617474722822696422292C63686172744F626A6563743A667D292C667D2C653D66756E6374696F6E2861297B72657475726E20632E66696C7465';
wwv_flow_api.g_varchar2_table(20) := '722866756E6374696F6E2862297B72657475726E20622E69643D3D3D617D295B305D7D3B72657475726E7B6164643A642C67657443686172743A657D7D2829297D28617065782E637573746F6D2C6A5175657279293B';
null;
 
end;
/

 
begin
 
wwv_flow_api.create_plugin_file (
  p_id => 1483836233474019068 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 1483751726531939169 + wwv_flow_api.g_id_offset
 ,p_file_name => 'apex.custom.chart.min.js'
 ,p_mime_type => 'application/x-javascript'
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
