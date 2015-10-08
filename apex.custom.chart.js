/*
* The MIT License (MIT)
* 
* Copyright (c) 2015 Tom Petrus
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/
(function(apex){
if ( apex.custom === undefined ) {
  apex.custom = {};
};
})(apex);

/** @author Tom Petrus
 *  @module apex.custom.chart
 *  @todo will not work with dashboard xml!!
 *  @todo chart id parameter, default to region id?
 *  @todo no data found message? - belongs in XML?
 *  @todo apexrefresh event on actual region, not on custom id (cc_+regionid)
 */
(function(parent, $, undefined){
  if (parent.chart === undefined) {
    parent.chart = function(){
    
      // polyfill IE8
      var serializeXmlNode = function (xmlNode) {
          if (typeof window.XMLSerializer != "undefined") {
              return (new window.XMLSerializer()).serializeToString(xmlNode);
          } else if (typeof xmlNode.xml != "undefined") {
              return xmlNode.xml;
          }
          return "";
      };
      
      /**
      * @todo keep an array of initialized charts for easy access. Especially for HTML5 charts
      * key/value pairs with ID / chart object
      */
      var gAllCharts = [];
      
      /**
       * @param pTargetSelector
       * @param pOptions an object with properties to define the chart
       * @param pOptions.type : CHART or GANTT
       * @param pOptions.rendertype : html or flash
       * @param pOptions.swfFile : location of the swf file for the chart
       * @param pOptions.preloaderFile : location of the swf file used for preload indication
       * @param pOptions.width : width of the chart
       * @param pOptions.height : height of the chart
       * @param pOptions.ajaxProcessName : name of the APEX on-demand process to call in order to retrieve data. ONLY data is expected back, and only the project or resource chart node will be processed.
       * @param pOptions.ajax an object with properties on how to retrieve data and defaults
       * @param pOptions.ajax.data {String|Object} Either the name of the APEX on-demand process to call in order to retrieve data, or an object with settings to pass on to $.ajax() ("A set of key/value pairs that configure the Ajax request."). Either way, the expected data type is XML !
       * ************((ONLY data is expected back, and only the project or resource chart node will be processed.))
       @param pOptions.ajax.defaults {String|Object} Either the name of the APEX on-demand process to call in order to retrieve defaults, or an object with settings to pass on to $.ajax() ("A set of key/value pairs that configure the Ajax request."). Either way, the expected data type is XML !
       * @param pOptions.defaultsLocation : where to retrieve an xml with the default settings of the chart. This xml will be fetched only once, it will not be fetched when the region is refreshed.
       * @param pOptions.chartType : CHART: data, GANTT: project_chart|resource_chart
       * @param pOptions.eventHandlers {Object} object with event handlers to bind to the chart. Use the chart's documented callbacks. The function's context will be set to the chart object
       * @return AnyChart object
       * @example 
       * apex.custom.chart.add($("#myChart1"), 
       *                  {"type":"CHART"
       *                  ,"rendertype":"FLASH_PREFERRED"
       *                  ,"swfFile": apex_img_dir + "flashchart/anygantt_4/swf/AnyGantt.swf"
       *                  ,"preloaderFile": apex_img_dir + "flashchart/anygantt_4/swf/Preloader.swf"
       *                  ,"width":"1200"
       *                  ,"height":"800"
       *                  ,"ajax":{"data":"GANTT_PROJECT_DATA", "defaults":"GANTT_DEFAULTS"}
       *                  ,"chartType":"project_chart"
       *                  ,"eventHandlers":{"taskSelect":function(e){ console.log( this.getTaskInfo(e.id) ); }}
       *                  }
       *                 );
       **/
      var add = function(pTargetSelector, pOptions){
        var lChart, lDefaults, lTarget$ = $(pTargetSelector);
        
        apex.debug("initialising chart");
        
        if ( pOptions.swfFile && pOptions.type === "GANTT") {
            lChart = new AnyGantt( pOptions.swfFile, pOptions.preloaderFile );
        } else {
            AnyChart.useBrowserResize = true;

            if ( pOptions.rendertype === "FLASH_PREFERRED" ) {  /** @todo: expand */
                AnyChart.renderingType = anychart.RenderingType.FLASH_PREFERRED;
                lChart = new AnyChart( pOptions.swfFile, pOptions.preloaderFile );
            } else {
                AnyChart.renderingType = anychart.RenderingType.SVG_ONLY;
                lChart = new AnyChart();
            }
        };
        
        lChart.wMode  = "transparent";

        if (pOptions.height === "99%") {
            lChart.height = $( window ).height() - 100;
        } else {
            lChart.height = pOptions.height;
        };
        if (pOptions.width === "100%") {
            lChart.width = pOptions.width; //dont know why apex lib has 1 here?
        } else {
            lChart.width = pOptions.width;
        };
        
        // if the taskSelect option is a function, bind it and provide the task as a parameter
        // otherwise do nothing
        /*if( pOptions.type === "GANTT" && $.isFunction(pOptions.taskSelect) ){
          var onTaskSelect = function (e) {              
              var task = lChart.getTaskInfo(e.id);
              pOptions.taskSelect.call(null, task);
          };
        
          lChart.addEventListener('taskSelect',onTaskSelect);
        };*/
        
        if ( $.type(pOptions.eventHandlers) === "object" ) {
          Object.keys(pOptions.eventHandlers).forEach(function(key){
            lChart.addEventListener(key, $.proxy( pOptions.eventHandlers[key], lChart) );
          });
        };
        
        // set up the refresh function
        var _refresh = function(pDefaults){
          var lDataPromise;
          
          apex.debug("refresh chart");
          lTarget$.trigger("apexbeforerefresh");

          if ( $.type(pOptions.ajax) === "object" && $.type(pOptions.ajax.data) === "string" ){
            lDataPromise = apex.server.process(pOptions.ajax.data,{},{dataType: "xml"});
          } else if ( $.type(pOptions.ajax) === "object" && $.type(pOptions.ajax.data) === "object" ) {
            lDataPromise = $.ajax(pOptions.ajax.data);
          };
          
          lDataPromise.done(function(pData){
            apex.debug('charttype: ' + pOptions.chartType);
            // find the project_chart or resource_chart node in the returned data
            var lNew = $(pData).find(pOptions.chartType);
            apex.debug(lNew);
            // find the x_chart node in the defaults
            var lOld = $(pDefaults).find(pOptions.chartType);
            apex.debug(lOld);
            // replace the x_chart node in the defaults with the passed data
            // this alters pDefaults! 
            /** @todo pDefaults should not get altered */
            lOld.replaceWith(lNew);            
            // serialize the xml
            var xmltext = serializeXmlNode(pDefaults);
            apex.debug(xmltext);
            // pass it to anychart
            lChart.setData(xmltext);
            lTarget$.trigger("apexafterrefresh");
            apex.debug("end refresh chart");
          });
        };
        
        // new location is before data is called for
        lChart.write( lTarget$[0] );

        // retrieve the defaults. Note that the defaultsLocation param could be a url etc, it doesn't have to be a file location
        // TODO: make this a function callback
        var lDefaultsPromise;
        if ( $.type(pOptions.ajax.defaults) === "string" ){
          lDefaultsPromise = apex.server.process(pOptions.ajax.defaults,{},{dataType: "xml"});
        } else if ( $.type(pOptions.ajax.defaults) === "object" && $.type(pOptions.ajax.defaults) === "object" ) {
          lDefaultsPromise = $.ajax(pOptions.ajax.defaults);
        };

        lDefaultsPromise.done(function(pDefaults){
          lDefaults = pDefaults;
          apex.debug("defaults fetched: ");
          apex.debug(lDefaults);
          // bind to the apexrefresh event and closure the defaults
          lTarget$.on("apexrefresh", function(){ _refresh(lDefaults); }).trigger("apexrefresh");
        });
        
        gAllCharts.push({"id":lTarget$.attr("id"),"chartObject":lChart});
        
        return lChart;
      };
      
      var getChart = function ( pId ) {
        return gAllCharts.filter(function(obj){
          return obj.id === pId;
        })[0];
      };
      
      // expose publicly
      return { add : add
             , getChart : getChart
             } ;
    }();
  };
})(apex.custom, jQuery);
