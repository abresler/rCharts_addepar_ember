#requires dev branch of rCharts
#require(devtools)
#install_github("rCharts","ramnathv",ref="dev")

require(quantmod)
require(rCharts)
#explicitly require rjson for toJSON
require(rjson)
#since ember uses handlebars templates
#we don't want rCharts and mustache
#to populate the ember handlebars templates
#inherit rCharts object to override the render method
rChartsAddepar <- setRefClass(
  "rChartsAddepar",
  contains = "rCharts",
  methods = list(
    initialize = function(){
      callSuper(); 
    },
    render = function (chartId = NULL, cdn = F, static = T, standalone = F) {
      params$dom <<- chartId %||% params$dom
      template = read_file(templates$page)
      assets = Map(
        "c",
        get_assets(
          LIB, static = static, cdn = cdn, standalone = standalone),
        html_assets
      )
      html = render_template(
        template,
        list(
          params = params,
          assets = assets, 
          chartId = params$dom,
          script = .self$html(params$dom),
          CODE = srccode,
          lib = LIB$name,
          tObj = tObj,
          container = container
        ), 
        partials = list(
          chartDiv = templates$chartDiv,
          afterScript = "<script></script>")
      )
      html = toObj(gsub(
        x = html,
        pattern  = "</body>",
        replacement = paste0(
          templates$afterScript,
          '
        </body>
        '
        )
      ))
      return(html)
  })
)
aTable <- rChartsAddepar$new()
aTable$setLib(
  #".",
  "http://timelyportfolio.github.io/rCharts_addepar_ember"
)
aTable$templates$page = "http://timelyportfolio.github.io/rCharts_addepar_ember/layouts/rChartAddepar.html"
aTable$setTemplate(
  afterScript='
        <script type="text/x-handlebars" data-template-name="application">
          <div class="col-md-10 col-md-offset-2 left-border main-content-container">
            <h1>Ember Table <small>Simple</small></h1>

            <div class="row">
              <div class="col-md-12">
                <div class="example-container">
                  <div class="ember-table-example-container" style="height:500px;">
                    {{table-component
                      hasFooter=false
                      columnsBinding="columns"
                      contentBinding="content"
                    }}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </script>  
  '
)
sp500 = getSymbols("^GSPC", auto.assign = F)
sp500.df = data.frame(index(sp500),sp500)
colnames(sp500.df) <- c(
  "Date",
  "Open",
  "High",
  "Low",
  "Close",
  "Volume",
  "Adj. Close"
)
aTable$params$data = sp500.df
#hack as is everything else for now
#to be able to specify column settings
aTable$params$columns = list(
  Date = list(
    textAlign = 'text-align-left',
    getCellContent = 
      "#! function(row) {return new Date(row['Date'] * 24 * 60 * 60 * 1000).toDateString();}!#"
  )
)

aTable


#### use the Addepar bar example with HairEye
require(plyr)
require(reshape2)

hairEye = data.frame(HairEyeColor)
hairEye.count <- ddply(
  hairEye,
  .(Hair,Eye),
  summarize,
  count = sum(Freq)/sum(hairEye$Freq) * 100
)
##or as percent of Hair
hairEye.count <- ddply(
  hairEye,
  .(Hair,Eye),
  summarize,
  count = sum(Freq)
)
hairEye.count <- dcast(hairEye.count,Hair ~ Eye, sum)
hairEye.count[,-1] <- hairEye.count[,-1] / apply(hairEye.count[,-1],MARGIN=1,FUN=sum) * 100


aBarTable <- rChartsAddepar$new()
aBarTable$setLib(
  "."#,
  #"http://timelyportfolio.github.io/rCharts_addepar_ember"
)
aBarTable$templates$page = "http://timelyportfolio.github.io/rCharts_addepar_ember/layouts/rChartAddepar.html"
aBarTable$templates$script = "layouts/chart_bar.html"
aBarTable$setTemplate(
  afterScript='
  <script type="text/x-handlebars" data-template-name="bar_table">
    <span class="bar-cell" {{bind-attr style="view.histogramStyle"}}>
    </span>
  </script>
  
  <script type="text/x-handlebars" data-template-name="application">
  <div class="col-md-10 col-md-offset-2 left-border main-content-container">
  <h1>Ember Table <small>Bar</small></h1>
  
  <div class="row">
  <div class="col-md-12">
  <div class="example-container">
  <div class="ember-table-example-container" style="height:400px;">
{{table-component
  hasHeader=true
  hasFooter=false
  rowHeight=30
  columnsBinding="columns"
  contentBinding="content"
}}
  </div>
  </div>
  </div>
  </div>
  </div>
  </script>
  '
)

aBarTable$params$data = hairEye.count
aBarTable
