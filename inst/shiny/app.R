library(shiny)
library(bs4Dash)
library(GAnnoViz)
library(ggplot2)
library(patchwork)
library(DT)
library(dplyr)

options(shiny.maxRequestSize = 1024 * 1024^2)

exampleImageFile <- function(fun) {
  p <- system.file("shiny", "www", "figures", sprintf("README-%s-1.png", fun), package = "GAnnoViz")
  if (nzchar(p) && file.exists(p)) return(p)
  p <- file.path("www", "figures", sprintf("README-%s-1.png", fun))
  if (file.exists(p)) return(normalizePath(p))
  p <- file.path("inst", "shiny", "www", "figures", sprintf("README-%s-1.png", fun))
}
sample_gff <- function() system.file("extdata", "example.gff3.gz", package = "GAnnoViz")
sample_deg <- function() system.file("extdata", "example.deg", package = "GAnnoViz")
sample_dmr <- function() system.file("extdata", "example.dmr", package = "GAnnoViz")
sample_fst <- function() system.file("extdata", "example.fst", package = "GAnnoViz")
placeholderImage <- function() system.file("shiny", "www", "Shinyapp.png", package = "GAnnoViz")

ui <- bs4DashPage(
  title = "GAnnoViz",
  fullscreen = TRUE,
  help = TRUE,
  dark = FALSE,
  scrollToTop = TRUE,
  header = bs4DashNavbar(skin = "light"),
  sidebar = bs4DashSidebar(
    disable = FALSE,
    skin = "dark",
    status = "warning",
    elevation = 3,
    collapsed = FALSE,
    minified = TRUE,
    expandOnHover = TRUE,
    fixed = TRUE,
    width = "300px",
    bs4SidebarMenu(
      id = "main_menu",
      bs4SidebarUserPanel(name = "GAnnoViz", image = "logo.png"),
      bs4SidebarHeader(title = "GAnnoViz"),
      bs4SidebarMenuItem(
        text = "Extract Features (7)",
        icon = icon("database"),
        startExpanded = FALSE,
        bs4SidebarMenuSubItem(
          text = "extract_promoters",
          icon = icon("r-project"),
          tabName = "extract_promoters"
        ),
        bs4SidebarMenuSubItem(
          text = "extract_utr5",
          icon = icon("r-project"),
          tabName = "extract_utr5"
        ),
        bs4SidebarMenuSubItem(
          text = "extract_genes",
          icon = icon("r-project"),
          tabName = "extract_genes"
        ),
        bs4SidebarMenuSubItem(
          text = "extract_mrnas",
          icon = icon("r-project"),
          tabName = "extract_mrnas"
        ),
        bs4SidebarMenuSubItem(
          text = "extract_cds",
          icon = icon("r-project"),
          tabName = "extract_cds"
        ),
        bs4SidebarMenuSubItem(
          text = "extract_exons",
          icon = icon("r-project"),
          tabName = "extract_exons"
        ),
        bs4SidebarMenuSubItem(
          text = "extract_utr3",
          icon = icon("r-project"),
          tabName = "extract_utr3"
        )
      ),
      bs4SidebarMenuItem(
        text = "Plot Structure (8)",
        icon = icon("circle-nodes"),
        startExpanded = TRUE,
        bs4SidebarMenuSubItem(
          text = "plot_gene_domains",
          icon = icon("r-project"),
          tabName = "plot_gene_domains"
        ),
        bs4SidebarMenuSubItem(
          text = "plot_gene_stats",
          icon = icon("r-project"),
          tabName = "plot_gene_stats"
        ),
        bs4SidebarMenuSubItem(
          text = "plot_gene_structure",
          icon = icon("r-project"),
          tabName = "plot_gene_structure"
        ),
        bs4SidebarMenuSubItem(
          text = "plot_interval_structure",
          icon = icon("r-project"),
          tabName = "plot_interval_structure"
        ),
        bs4SidebarMenuSubItem(
          text = "plot_interval_flank",
          icon = icon("r-project"),
          tabName = "plot_interval_flank"
        ),
        bs4SidebarMenuSubItem(
          text = "plot_chrom_structure",
          icon = icon("r-project"),
          tabName = "plot_chrom_structure"
        ),
        bs4SidebarMenuSubItem(
          text = "plot_chrom_genes",
          icon = icon("r-project"),
          tabName = "plot_chrom_genes"
        ),
        bs4SidebarMenuSubItem(
          text = "plot_chrom_heatmap",
          icon = icon("r-project"),
          tabName = "plot_chrom_heatmap"
        )
      ),
      bs4SidebarMenuItem(
        text = "DEG Anno & Viz (4)",
        icon = icon("chart-simple"),
        startExpanded = FALSE,
        bs4SidebarMenuSubItem(
          text = "anno_deg_chrom",
          icon = icon("r-project"),
          tabName = "anno_deg_chrom"
        ),
        bs4SidebarMenuSubItem(
          text = "plot_deg_chrom",
          icon = icon("r-project"),
          tabName = "plot_deg_chrom"
        ),
        bs4SidebarMenuSubItem(
          text = "plot_deg_exp",
          icon = icon("r-project"),
          tabName = "plot_deg_exp"
        ),
        bs4SidebarMenuSubItem(
          text = "plot_deg_volcano",
          icon = icon("r-project"),
          tabName = "plot_deg_volcano"
        )
      ),
      bs4SidebarMenuItem(
        text = "SNP Anno & Plot (3)",
        icon = icon("arrows-to-dot"),
        startExpanded = FALSE,
        bs4SidebarMenuSubItem(
          text = "plot_snp_density",
          icon = icon("r-project"),
          tabName = "plot_snp_density"
        ),
        bs4SidebarMenuSubItem(
          text = "plot_snp_fst",
          icon = icon("r-project"),
          tabName = "plot_snp_fst"
        ),
        bs4SidebarMenuSubItem(
          text = "plot_snp_anno",
          icon = icon("r-project"),
          tabName = "plot_snp_anno"
        )
      ),
      bs4SidebarMenuItem(
        text = "DMG Anno & Plot (4)",
        icon = icon("atom"),
        startExpanded = FALSE,
        bs4SidebarMenuSubItem(
          text = "anno_fst_dmr",
          icon = icon("r-project"),
          tabName = "anno_fst_dmr"
        ),
        bs4SidebarMenuSubItem(
          text = "plot_dmg_chrom",
          icon = icon("r-project"),
          tabName = "plot_dmg_chrom"
        ),
        bs4SidebarMenuSubItem(
          text = "plot_dmg_exp",
          icon = icon("r-project"),
          tabName = "plot_dmg_exp"
        ),
        bs4SidebarMenuSubItem(
          text = "plot_dmg_trend",
          icon = icon("r-project"),
          tabName = "plot_dmg_trend"
        )
      )
    )
  ),
  body = bs4DashBody(
    tags$head(
      tags$link(rel = "stylesheet", href = "style.css"),
      tags$style(
        HTML(
          "
            #sidebarId {
              border-radius: 15px;
              transform: scale(0.98);
            }
            .main-header {
              margin: 3px;
              padding: 5px;
              border: 1px solid #eeeeee;
              border-radius: 30px;
              box-shadow: 0px 10px 20px #cccccc;
              transform: scale(0.8);
              background-image: radial-gradient(circle 720px at 50% 50%, #ff000033 0%, #00008811 50%, #00880011 100%);
            }
            .wrapper {
              background-color: #efefef88;
            }
            .card-title {
              color: #000000;
              font-weight: bold;
            }
            .card-body {
              height: 840px;
              overflow-y: auto;
              scrollbar-width: thin;
            }
            .action-button {
            	width: 100%;
            	background-color: #ff880088;
            	border-radius: 10px;
            	color: #333333;
            	font-weight: bold;
            }
            .shiny-download-link {
              width: 100%;
            	background-color: #0088aa88;
            	border-radius: 10px;
            	color: #333333;
            	font-weight: bold;
            }
            .form-control, .selectize-input, .shiny-input-number, .shiny-input-select, .custom-file-input, .custom-file-label {
              border-radius: 10px;
              background-image: radial-gradient(circle 200px at 50% 50%, #00008808 0%, #00880008 100%);
            }
            .irs-line, .irs-bar, .irs-handle {
              border-radius: 10px !important;
            }
            .tooltip-inner {
              font-size: 12px;
              background-color: #333333;
              box-shadow: 0px 0px 5px #888888;
              border-radius: 10px;
            }
            .fa-exclamation-circle {
              color: #333333 !important;
            }
            #right-info-panel {
              position: fixed;
              right: 15px;
              top: 80px;
              width: 23%;
              z-index: 1000;
              height: 850px;
              overflow-y: auto;
              scrollbar-width: thin;
            }
            #right-info-panel img {
              border-radius: 10px;
              width: 100%;
              height: auto;
            }
          "
        )
      )
    ),
    tags$script(HTML("
      $(function(){
        var paramTips = {
          'GFF/GTF file':'Genomic structural annotation GFF3/GTF file path.',
          'Format':'Format of GFF3/GTF file. (\"auto\", \"gff3\", \"gtf\").',
          'Gene ID':'Gene id same as GFF3/GTF. (necessary).',
          'Promoter upstream':'Promoter upstream (bp). (2000).',
          'Promoter downstream':'Promoter downstream (bp). (200).',
          'Feature alpha':'Elements alpha. (0.8).',
          'Intron width':'Intron line width. (1).',
          'X breaks':'X axis breaks number. (10).',
          'Arrow length':'Intron arrows length (pt). (1).',
          'Arrow count':'Intron arrow number bold. (1).',
          'Arrow unit':'Intron arrow length unit. (\"pt\", \"mm\").',
          'Promoter color':'Promoter color. (\"#ff8800\").',
          '5\\'UTR color':'5\\'UTR color. (\"#008833\").',
          '3\\'UTR color':'3\\'UTR color. (\"#ff0033\").',
          'Exon color':'Exon color. (\"#0033ff\").',
          'Intron color':'Intron color. (\"#333333\").',
          'Width (in)':'Plot width in inches.',
          'Height (in)':'Plot height in inches.',
          'DPI':'Plot resolution (dots per inch).',
          'Orientation':'Coordinate orientation. (\"horizontal\", \"vertical\").',
          'Bar width':'Chromosome bar width. (0.6).',
          'Chrom alpha':'Chromosome alpha. (1).',
          'Gene width':'Gene bar width. (0.6).',
          'Chrom color':'Chromosome color. (\"#333333\").',
          'Gene color':'Gene color. (\"#ff0000\").',
          'Bar color':'Bar color.',
          'Telomere color':'Telomere color. (\"#ff0000\").',
          'Label size':'Text size for gene labels. (3).',
          'Feature':'Feature type (gene, exon, CDS, promoter, etc.).',
          'Bin size':'Bin size (bp) for FST calculation. (2000).',
          'Alpha':'Point alpha. (0.3).',
          'ID column':'Gene ID column name in DEG table.',
          'FC column':'FoldChange column name in DEG table.',
          'Use strand':'Whether to respect actual strand instead of \"*\". (FALSE).',
          'Drop unmapped':'Whether to drop unmapped chromosomes. (TRUE).',
          'Violin scale':'Violin scale mode. (\"count\", \"area\", \"width\").',
          'Violin border':'Violin border width. (0.5).',
          'Point shape':'Points shape (0-25). (8).',
          'Point size':'Point size. (1).',
          'Jitter width':'Horizontal jitter width. (0.2).',
          'Hyper color':'Point color for hyper-methylated/up-regulated genes.',
          'Hypo color':'Point color for hypo-methylated/down-regulated genes.',
          'Palette':'Color palette. (\"Set 2\", \"Set 3\", \"Warm\", \"Cold\", \"Dynamic\", \"Viridis\", \"Plasma\", \"Inferno\", \"Rocket\", \"Mako\").',
          'Legend columns':'Legend columns per row. (2).',
          'Smooth span':'Span for local regression smoothing. (0.1).',
          'Up color':'Color for up-regulated genes.',
          'Down color':'Color for down-regulated genes.',
          'Mark style':'Marker style for DMGs. (\"point\", \"line\").',
          'Line width':'Line width. (0.6).',
          'Line height':'Line height relative to bar radius. (0.8).',
          'Metric':'Aggregation metric for bin fill. (\"fst_mean\", \"variant_count\").',
          'Top N':'Number of top genes to annotate. (20).',
          'Connector dx1':'Connector horizontal length 1. (0.1).',
          'Connector dx2':'Connector horizontal length 2. (0.1).',
          'Gap frac':'Minimum vertical gap between labels (fraction of chromosome length). (0.02).',
          'Info':'Information to extract (all, chrom_id, gene_id, range, etc.).'
        };
        $('.card .shiny-input-container > label, .card .form-group > label, .card label[for]').each(function(){
          var t = $(this).text().trim();
          var tip = paramTips[t] || ('Package help: ' + t);
          if($(this).find('.fa-exclamation-circle').length === 0){
            var icon = $('<i>')
              .addClass('fa fa-exclamation-circle')
              .attr('data-toggle','tooltip')
              .attr('title', tip)
              .css({color:'#ff8800',fontSize:'0.9em',marginLeft:'5px',cursor:'pointer'});
            icon.on('click', function(e){
              e.preventDefault();
              e.stopPropagation();
            });
            $(this).append(icon);
          }
        });
        $('[data-toggle=\"tooltip\"]').tooltip({container:'body', boundary:'viewport'});
      });
    ")),

    bs4TabItems(
      bs4TabItem(tabName = "plot_gene_structure", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = " Parameters",
            icon = icon("gear"),
            status = "info",
            solidHeader = FALSE,
            width = 12,
            actionButton(
              inputId = "run_plot_gene_structure",
              label = "Run",
              icon = icon("circle-play"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "download_plot_gene_structure",
              label = "Download",
              icon = icon("cloud-arrow-down"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "session_download_plot_gene_structure",
              label = "Version, Parameter, MD5",
              icon = icon("circle-info"),
              style = "width: 100%",
              class = "btn-block"
            ),
            br(),
            fileInput(inputId = "gff_file_gene", label = "GFF/GTF file"),
            selectInput(
              inputId = "gff_format_gene",
              label = "Format",
              choices = c("auto", "gff3", "gtf"),
              selected = "auto"
            ),
            textInput(
              inputId = "gene_id",
              label = "Gene ID",
              value = "ENSMUSG00000025935"
            ),
            numericInput(
              inputId = "upstream",
              label = "Promoter upstream",
              value = 2000,
              min = 0,
              step = 100
            ),
            numericInput(
              inputId = "downstream",
              label = "Promoter downstream",
              value = 200,
              min = 0,
              step = 50
            ),
            sliderInput(
              inputId = "feature_alpha",
              label = "Feature alpha",
              min = 0,
              max = 1,
              value = 0.8,
              step = 0.05
            ),
            numericInput(
              inputId = "intron_width",
              label = "Intron width",
              value = 1,
              min = 0,
              step = 0.5
            ),
            numericInput(
              inputId = "x_breaks",
              label = "X breaks",
              value = 10,
              min = 2,
              step = 1
            ),
            numericInput(
              inputId = "arrow_length",
              label = "Arrow length",
              value = 5,
              min = 1,
              step = 1
            ),
            numericInput(
              inputId = "arrow_count",
              label = "Arrow count",
              value = 1,
              min = 0,
              step = 1
            ),
            selectInput(
              inputId = "arrow_unit",
              label = "Arrow unit",
              choices = c("pt", "mm", "cm", "inches"),
              selected = "pt"
            ),
            textInput(
              inputId = "promoter_color",
              label = "Promoter color",
              value = "#ff8800"
            ),
            textInput(
              inputId = "utr5_color",
              label = "5'UTR color",
              value = "#008833"
            ),
            textInput(
              inputId = "utr3_color",
              label = "3'UTR color",
              value = "#ff0033"
            ),
            textInput(
              inputId = "exon_color",
              label = "Exon color",
              value = "#0033ff"
            ),
            textInput(
              inputId = "intron_color",
              label = "Intron color",
              value = "#333333"
            ),
            numericInput(
              inputId = "plot_width_gene_structure",
              label = "Width (in)",
              value = 10,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_height_gene_structure",
              label = "Height (in)",
              value = 6,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_dpi_gene_structure",
              label = "DPI",
              value = 300,
              min = 72,
              step = 10
            ),
            selectInput(
              inputId = "plot_format_gene_structure",
              label = "Format",
              choices = c("pdf", "jpeg"),
              selected = "pdf"
            )
          )
        ), column(
          width = 6,
          bs4Card(
            title = " Plot",
            icon = icon("chart-pie"),
            status = "danger",
            solidHeader = FALSE,
            width = 12,
            plotOutput("plot_gene_structure", height = "600px")
          )
        ), column(
          width = 3,
          bs4Card(
            title = "Plot gene structure",
            status = "warning",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. App Name:"),
            br(),
            tags$b("plot_gene_structure"),
            br(),br(),
            tags$b("2. Function Description"),
            br(),
            p("Plot gene structure (Promoter, 3'UTR, Exon, Intron, 5'UTR)."),
            tags$b("3. Demo Output"),
            br(),br(),
            imageOutput("example_plot_gene_structure", width = 300, height = NULL)
          ),
          bs4Card(
            title = "Example Datasets",
            status = "info",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. Genomic Annotation (GFF3/GTF)"),
            br(),
            tags$b("Mus musculus: GRCm39.115"),
            downloadButton("dl_gff_gtf_1", "Download GFF3", icon = icon("download")),
            br(), br(),
            tags$b("2. Differentially expressed genes (DESeq2)"),
            br(),

            downloadButton("dl_deg_deg_1", "Download DEG", icon = icon("download")),
            br(), br(),
            tags$b("3. Differentially methylated regions (MethylKit)"),
            br(),

            downloadButton("dl_dmr_dmg_1", "Download DMR", icon = icon("download")),
            br(), br(),
            tags$b("4. SNP mutation site (VCFtools)"),
            br(),

            downloadButton("dl_fst_snp_1", "Download SNP", icon = icon("download"))
          )
        )
      )),

      bs4TabItem(tabName = "anno_deg_chrom", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = " Parameters",
            icon = icon("gear"),
            status = "info",
            solidHeader = FALSE,
            width = 12,
            actionButton(
              inputId = "run_anno_deg_chrom",
              label = "Run",
              icon = icon("circle-play"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "download_table_anno_deg_chrom",
              label = "Download",
              icon = icon("cloud-arrow-down"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "session_download_table_anno_deg_chrom",
              label = "Version, Parameter, MD5",
              icon = icon("circle-info"),
              style = "width: 100%",
              class = "btn-block"
            ),
            br(),
            fileInput(inputId = "deg_file_anno", label = "DEG table"),
            fileInput(inputId = "gff_file_deg_anno", label = "GFF/GTF file"),
            selectInput(
              inputId = "gff_format_deg_anno",
              label = "Format",
              choices = c("auto", "gff3", "gtf"),
              selected = "auto"
            ),
            textInput(
              inputId = "id_col_anno",
              label = "ID column",
              value = "GeneID"
            ),
            textInput(
              inputId = "fc_col_anno",
              label = "FC column",
              value = "log2FoldChange"
            ),
            checkboxInput(
              inputId = "use_strand_anno",
              label = "Use strand",
              value = FALSE
            ),
            checkboxInput(
              inputId = "drop_unmapped_anno",
              label = "Drop unmapped",
              value = TRUE
            )
          )
        ), column(
          width = 6,
          bs4Card(
            title = "Data",
            status = "primary",
            solidHeader = FALSE,
            width = 12,
            DT::dataTableOutput("table_anno_deg_chrom")
          )
        ), column(
          width = 3,
          bs4Card(
            title = "Annotate DEGs on chromosomes",
            status = "warning",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. App Name:"),
            br(),
            tags$b("anno_deg_chrom"),
            br(),br(),
            tags$b("2. Function Description"),
            br(),
            p("Annotate and plot differentially expressed genes (DEGs) on chromosomes."),
            tags$b("3. Demo Output"),
            br(),br(),
            imageOutput("example_anno_deg_chrom", width = 300, height = NULL)
          ),
          bs4Card(
            title = "Example Datasets",
            status = "info",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. Genomic Annotation (GFF3/GTF)"),
            br(),
            tags$b("Mus musculus: GRCm39.115"),
            downloadButton("dl_gff_gtf_2", "Download GFF3", icon = icon("download")),
            br(), br(),
            tags$b("2. Differentially expressed genes (DESeq2)"),
            br(),

            downloadButton("dl_deg_deg_2", "Download DEG", icon = icon("download")),
            br(), br(),
            tags$b("3. Differentially methylated regions (MethylKit)"),
            br(),

            downloadButton("dl_dmr_dmg_2", "Download DMR", icon = icon("download")),
            br(), br(),
            tags$b("4. SNP mutation site (VCFtools)"),
            br(),

            downloadButton("dl_fst_snp_2", "Download SNP", icon = icon("download"))
          )
        )
      )),

      bs4TabItem(tabName = "plot_gene_domains", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = " Parameters",
            icon = icon("gear"),
            status = "info",
            solidHeader = FALSE,
            width = 12,
            actionButton(
              inputId = "run_plot_gene_domains",
              label = "Run",
              icon = icon("circle-play"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "download_plot_gene_domains",
              label = "Download",
              icon = icon("cloud-arrow-down"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "session_download_plot_gene_domains",
              label = "Version, Parameter, MD5",
              icon = icon("circle-info"),
              style = "width: 100%",
              class = "btn-block"
            ),
            br(),
            textInput(
              inputId = "gene_name_domains",
              label = "Gene name",
              value = "TP53"
            ),
            textInput(
              inputId = "species_domains",
              label = "Species",
              value = "hsapiens"
            ),
            textInput(
              inputId = "transcript_id_domains",
              label = "Transcript ID",
              value = ""
            ),
            selectInput(
              inputId = "transcript_choice_domains",
              label = "Transcript choice",
              choices = c("longest", "canonical"),
              selected = "longest"
            ),
            selectInput(
              inputId = "palette_domains",
              label = "Palette",
              choices = c("Set 2", "Set 3", "Warm", "Cold", "Dynamic", "Viridis", "Plasma", "Inferno", "Rocket", "Mako"),
              selected = "Set 2"
            ),
            numericInput(
              inputId = "legend_ncol_domains",
              label = "Legend columns",
              value = 2,
              min = 1,
              step = 1
            ),
            numericInput(
              inputId = "plot_width_gene_domains",
              label = "Width (in)",
              value = 10,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_height_gene_domains",
              label = "Height (in)",
              value = 6,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_dpi_gene_domains",
              label = "DPI",
              value = 300,
              min = 72,
              step = 10
            ),
            selectInput(
              inputId = "plot_format_gene_domains",
              label = "Format",
              choices = c("pdf", "jpeg"),
              selected = "pdf"
            )
          )
        ), column(
          width = 6,
          bs4Card(
            title = " Plot",
            icon = icon("chart-pie"),
            status = "danger",
            solidHeader = FALSE,
            width = 12,
            plotOutput("plot_gene_domains", height = "600px")
          )
        ), column(
          width = 3,
          bs4Card(
            title = "Plot protein domains",
            status = "warning",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. App Name:"),
            br(),
            tags$b("plot_gene_domains"),
            br(),br(),
            tags$b("2. Function Description"),
            br(),
            p("Plot protein domains from Ensembl."),
            tags$b("3. Demo Output"),
            br(),br(),
            imageOutput("example_plot_gene_domains", width = 300, height = NULL)
          ),
          bs4Card(
            title = "Example Datasets",
            status = "info",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. Genomic Annotation (GFF3/GTF)"),
            br(),
            tags$b("Mus musculus: GRCm39.115"),
            downloadButton("dl_gff_gtf_3", "Download GFF3", icon = icon("download")),
            br(), br(),
            tags$b("2. Differentially expressed genes (DESeq2)"),
            br(),

            downloadButton("dl_deg_deg_3", "Download DEG", icon = icon("download")),
            br(), br(),
            tags$b("3. Differentially methylated regions (MethylKit)"),
            br(),

            downloadButton("dl_dmr_dmg_3", "Download DMR", icon = icon("download")),
            br(), br(),
            tags$b("4. SNP mutation site (VCFtools)"),
            br(),

            downloadButton("dl_fst_snp_3", "Download SNP", icon = icon("download"))
          )
        )
      )),

      bs4TabItem(tabName = "plot_dmg_trend", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = " Parameters",
            icon = icon("gear"),
            status = "info",
            solidHeader = FALSE,
            width = 12,
            actionButton(
              inputId = "run_plot_dmg_trend",
              label = "Run",
              icon = icon("circle-play"),
              class = "btn-block"
            ),
            downloadButton(
              outputId = "download_plot_dmg_trend",
              label = "Download",
              icon = icon("cloud-arrow-down"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "session_download_plot_dmg_trend",
              label = "Version, Parameter, MD5",
              icon = icon("circle-info"),
              style = "width: 100%",
              class = "btn-block"
            ),
            br(),
            fileInput(inputId = "dmr_file_trend", label = "DMR table"),
            textInput(
              inputId = "chrom_id_trend",
              label = "Chrom ID",
              value = "chr1"
            ),
            sliderInput(
              inputId = "smooth_span_trend",
              label = "Smooth span",
              min = 0.05,
              max = 1,
              value = 0.1,
              step = 0.05
            ),
            textInput(
              inputId = "hyper_color_trend",
              label = "Hyper color",
              value = "#ff000055"
            ),
            textInput(
              inputId = "hypo_color_trend",
              label = "Hypo color",
              value = "#00880055"
            ),
            numericInput(
              inputId = "point_size_trend",
              label = "Point size",
              value = 3,
              min = 0.5,
              step = 0.5
            ),
            sliderInput(
              inputId = "point_alpha_trend",
              label = "Point alpha",
              min = 0,
              max = 1,
              value = 0.5,
              step = 0.05
            ),
            numericInput(
              inputId = "plot_width_dmg_trend",
              label = "Width (in)",
              value = 10,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_height_dmg_trend",
              label = "Height (in)",
              value = 6,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_dpi_dmg_trend",
              label = "DPI",
              value = 300,
              min = 72,
              step = 10
            ),
            selectInput(
              inputId = "plot_format_dmg_trend",
              label = "Format",
              choices = c("pdf", "jpeg"),
              selected = "pdf"
            )
          )
        ), column(
          width = 6,
          bs4Card(
            title = " Plot",
            icon = icon("chart-pie"),
            status = "danger",
            solidHeader = FALSE,
            width = 12,
            plotOutput("plot_dmg_trend", height = "600px")
          )
        ), column(
          width = 3,
          bs4Card(
            title = "Plot chromosomal DMGs trend",
            status = "warning",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. App Name:"),
            br(),
            tags$b("plot_dmg_trend"),
            br(),br(),
            tags$b("2. Function Description"),
            br(),
            p("Plot chromosomal DMGs trend."),
            tags$b("3. Demo Output"),
            br(),br(),
            imageOutput("example_plot_dmg_trend", width = 300, height = NULL)
          ),
          bs4Card(
            title = "Example Datasets",
            status = "info",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. Genomic Annotation (GFF3/GTF)"),
            br(),
            tags$b("Mus musculus: GRCm39.115"),
            downloadButton("dl_gff_gtf_4", "Download GFF3", icon = icon("download")),
            br(), br(),
            tags$b("2. Differentially expressed genes (DESeq2)"),
            br(),

            downloadButton("dl_deg_deg_4", "Download DEG", icon = icon("download")),
            br(), br(),
            tags$b("3. Differentially methylated regions (MethylKit)"),
            br(),

            downloadButton("dl_dmr_dmg_4", "Download DMR", icon = icon("download")),
            br(), br(),
            tags$b("4. SNP mutation site (VCFtools)"),
            br(),

            downloadButton("dl_fst_snp_4", "Download SNP", icon = icon("download"))
          )
        )
      )),

      bs4TabItem(tabName = "plot_interval_structure", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = " Parameters",
            icon = icon("gear"),
            status = "info",
            solidHeader = FALSE,
            width = 12,
            actionButton(
              inputId = "run_plot_interval_structure",
              label = "Run",
              icon = icon("circle-play"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "download_plot_interval_structure",
              label = "Download",
              icon = icon("cloud-arrow-down"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "session_download_plot_interval_structure",
              label = "Version, Parameter, MD5",
              icon = icon("circle-info"),
              style = "width: 100%",
              class = "btn-block"
            ),
            br(),
            fileInput(inputId = "gff_file_interval", label = "GFF/GTF file"),
            selectInput(
              inputId = "gff_format_interval",
              label = "Format",
              choices = c("auto", "gff3", "gtf"),
              selected = "auto"
            ),
            textInput(
              inputId = "chrom_id",
              label = "Chrom ID",
              value = "chr1"
            ),
            numericInput(
              inputId = "win_start",
              label = "Start",
              value = 13600000,
              min = 0,
              step = 1000
            ),
            numericInput(
              inputId = "win_end",
              label = "End",
              value = 13800000,
              min = 0,
              step = 1000
            ),
            numericInput(
              inputId = "x_breaks_interval",
              label = "X breaks",
              value = 10,
              min = 2,
              step = 1
            ),
            numericInput(
              inputId = "upstream_interval",
              label = "Promoter upstream",
              value = 2000,
              min = 0,
              step = 100
            ),
            numericInput(
              inputId = "downstream_interval",
              label = "Promoter downstream",
              value = 200,
              min = 0,
              step = 50
            ),
            sliderInput(
              inputId = "feature_alpha_interval",
              label = "Feature alpha",
              min = 0,
              max = 1,
              value = 0.8,
              step = 0.05
            ),
            numericInput(
              inputId = "intron_width_interval",
              label = "Intron width",
              value = 1,
              min = 0,
              step = 0.5
            ),
            numericInput(
              inputId = "arrow_length_interval",
              label = "Arrow length",
              value = 5,
              min = 1,
              step = 1
            ),
            numericInput(
              inputId = "arrow_count_interval",
              label = "Arrow count",
              value = 1,
              min = 0,
              step = 1
            ),
            selectInput(
              inputId = "arrow_unit_interval",
              label = "Arrow unit",
              choices = c("pt", "mm", "cm", "inches"),
              selected = "pt"
            ),
            textInput(
              inputId = "promoter_color_interval",
              label = "Promoter color",
              value = "#ff8800"
            ),
            textInput(
              inputId = "utr5_color_interval",
              label = "5'UTR color",
              value = "#008833"
            ),
            textInput(
              inputId = "utr3_color_interval",
              label = "3'UTR color",
              value = "#ff0033"
            ),
            textInput(
              inputId = "exon_color_interval",
              label = "Exon color",
              value = "#0033ff"
            ),
            textInput(
              inputId = "intron_color_interval",
              label = "Intron color",
              value = "#333333"
            ),
            numericInput(
              inputId = "plot_width_interval_structure",
              label = "Width (in)",
              value = 10,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_height_interval_structure",
              label = "Height (in)",
              value = 6,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_dpi_interval_structure",
              label = "DPI",
              value = 300,
              min = 72,
              step = 10
            ),
            selectInput(
              inputId = "plot_format_interval_structure",
              label = "Format",
              choices = c("pdf", "jpeg"),
              selected = "pdf"
            )
          )
        ), column(
          width = 6,
          bs4Card(
            title = " Plot",
            icon = icon("chart-pie"),
            status = "danger",
            solidHeader = FALSE,
            width = 12,
            plotOutput("plot_interval_structure", height = "600px")
          )
        ), column(
          width = 3,
          bs4Card(
            title = "Plot gene structures for interval",
            status = "warning",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. App Name:"),
            br(),
            tags$b("plot_interval_structure"),
            br(),br(),
            tags$b("2. Function Description"),
            br(),
            p("Plot gene structures for a genomic interval."),
            tags$b("3. Demo Output"),
            br(),br(),
            imageOutput("example_plot_interval_structure", width = 300, height = NULL)
          ),
          bs4Card(
            title = "Example Datasets",
            status = "info",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. Genomic Annotation (GFF3/GTF)"),
            br(),
            tags$b("Mus musculus: GRCm39.115"),
            downloadButton("dl_gff_gtf_5", "Download GFF3", icon = icon("download")),
            br(), br(),
            tags$b("2. Differentially expressed genes (DESeq2)"),
            br(),

            downloadButton("dl_deg_deg_5", "Download DEG", icon = icon("download")),
            br(), br(),
            tags$b("3. Differentially methylated regions (MethylKit)"),
            br(),

            downloadButton("dl_dmr_dmg_5", "Download DMR", icon = icon("download")),
            br(), br(),
            tags$b("4. SNP mutation site (VCFtools)"),
            br(),

            downloadButton("dl_fst_snp_5", "Download SNP", icon = icon("download"))
          )
        )
      )),

      bs4TabItem(tabName = "plot_interval_flank", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = " Parameters",
            icon = icon("gear"),
            status = "info",
            solidHeader = FALSE,
            width = 12,
            actionButton(
              inputId = "run_plot_interval_flank",
              label = "Run",
              icon = icon("circle-play"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "download_plot_interval_flank",
              label = "Download",
              icon = icon("cloud-arrow-down"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "session_download_plot_interval_flank",
              label = "Version, Parameter, MD5",
              icon = icon("circle-info"),
              style = "width: 100%",
              class = "btn-block"
            ),
            br(),
            fileInput(inputId = "gff_file_flank", label = "GFF/GTF file"),
            selectInput(
              inputId = "gff_format_flank",
              label = "Format",
              choices = c("auto", "gff3", "gtf"),
              selected = "auto"
            ),
            textInput(
              inputId = "flank_gene_id",
              label = "Gene ID",
              value = "ENSMUSG00000025935"
            ),
            numericInput(
              inputId = "flank_upstream",
              label = "Flank upstream",
              value = 200000,
              min = 0,
              step = 1000
            ),
            numericInput(
              inputId = "flank_downstream",
              label = "Flank downstream",
              value = 200000,
              min = 0,
              step = 1000
            ),
            checkboxInput(
              inputId = "show_promoters",
              label = "Show promoters",
              value = TRUE
            ),
            numericInput(
              inputId = "upstream_flank",
              label = "Promoter upstream",
              value = 2000,
              min = 0,
              step = 100
            ),
            numericInput(
              inputId = "downstream_flank",
              label = "Promoter downstream",
              value = 200,
              min = 0,
              step = 50
            ),
            numericInput(
              inputId = "arrow_length_flank",
              label = "Arrow length",
              value = 5,
              min = 1,
              step = 1
            ),
            selectInput(
              inputId = "arrow_unit_flank",
              label = "Arrow unit",
              choices = c("pt", "mm", "cm", "inches"),
              selected = "pt"
            ),
            textInput(
              inputId = "gene_color_flank",
              label = "Gene color",
              value = "#0088ff"
            ),
            textInput(
              inputId = "promoter_color_flank",
              label = "Promoter color",
              value = "#ff8800"
            ),
            numericInput(
              inputId = "label_size_flank",
              label = "Label size",
              value = 3,
              min = 1,
              step = 1
            ),
            numericInput(
              inputId = "plot_width_interval_flank",
              label = "Width (in)",
              value = 10,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_height_interval_flank",
              label = "Height (in)",
              value = 6,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_dpi_interval_flank",
              label = "DPI",
              value = 300,
              min = 72,
              step = 10
            ),
            selectInput(
              inputId = "plot_format_interval_flank",
              label = "Format",
              choices = c("pdf", "jpeg"),
              selected = "pdf"
            )
          )
        ), column(
          width = 6,
          bs4Card(
            title = " Plot",
            icon = icon("chart-pie"),
            status = "danger",
            solidHeader = FALSE,
            width = 12,
            plotOutput("plot_interval_flank", height = "600px")
          )
        ), column(
          width = 3,
          bs4Card(
            title = "Gene neighborhood architecture",
            status = "warning",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. App Name:"),
            br(),
            tags$b("plot_interval_flank"),
            br(),br(),
            tags$b("2. Function Description"),
            br(),
            p("Plot gene neighborhood around a focal gene."),
            tags$b("3. Demo Output"),
            br(),br(),
            imageOutput("example_plot_interval_flank", width = 300, height = NULL)
          ),
          bs4Card(
            title = "Example Datasets",
            status = "info",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. Genomic Annotation (GFF3/GTF)"),
            br(),
            tags$b("Mus musculus: GRCm39.115"),
            downloadButton("dl_gff_gtf_6", "Download GFF3", icon = icon("download")),
            br(), br(),
            tags$b("2. Differentially expressed genes (DESeq2)"),
            br(),

            downloadButton("dl_deg_deg_6", "Download DEG", icon = icon("download")),
            br(), br(),
            tags$b("3. Differentially methylated regions (MethylKit)"),
            br(),

            downloadButton("dl_dmr_dmg_6", "Download DMR", icon = icon("download")),
            br(), br(),
            tags$b("4. SNP mutation site (VCFtools)"),
            br(),

            downloadButton("dl_fst_snp_6", "Download SNP", icon = icon("download"))
          )
        )
      )),

      bs4TabItem(tabName = "plot_chrom_structure", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = " Parameters",
            icon = icon("gear"),
            status = "info",
            solidHeader = FALSE,
            width = 12,
            actionButton(
              inputId = "run_plot_chrom_structure",
              label = "Run",
              icon = icon("circle-play"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "download_plot_chrom_structure",
              label = "Download",
              icon = icon("cloud-arrow-down"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "session_download_plot_chrom_structure",
              label = "Version, Parameter, MD5",
              icon = icon("circle-info"),
              style = "width: 100%",
              class = "btn-block"
            ),
            br(),
            fileInput(inputId = "gff_file_chrom", label = "GFF/GTF file"),
            selectInput(
              inputId = "gff_format_chrom",
              label = "Format",
              choices = c("auto", "gff3", "gtf"),
              selected = "auto"
            ),
            selectInput(
              inputId = "chrom_orientation",
              label = "Orientation",
              choices = c("vertical", "horizontal"),
              selected = "vertical"
            ),
            sliderInput(
              inputId = "bar_width",
              label = "Bar width",
              min = 0.1,
              max = 1,
              value = 0.6,
              step = 0.05
            ),
            sliderInput(
              inputId = "chrom_alpha",
              label = "Chrom alpha",
              min = 0,
              max = 1,
              value = 0.1,
              step = 0.05
            ),
            sliderInput(
              inputId = "gene_width",
              label = "Gene width",
              min = 0.1,
              max = 1,
              value = 0.5,
              step = 0.05
            ),
            textInput(
              inputId = "chrom_color",
              label = "Chrom color",
              value = "#008888"
            ),
            textInput(
              inputId = "gene_color_chrom",
              label = "Gene color",
              value = "#0088ff"
            ),
            textInput(
              inputId = "telomere_color",
              label = "Telomere color",
              value = "#ff0000"
            ),
            numericInput(
              inputId = "label_size_chrom",
              label = "Label size",
              value = 3,
              min = 1,
              step = 1
            )
            ,
            numericInput(
              inputId = "plot_width_chrom_structure",
              label = "Width (in)",
              value = 10,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_height_chrom_structure",
              label = "Height (in)",
              value = 6,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_dpi_chrom_structure",
              label = "DPI",
              value = 300,
              min = 72,
              step = 10
            ),
            selectInput(
              inputId = "plot_format_chrom_structure",
              label = "Format",
              choices = c("pdf", "jpeg"),
              selected = "pdf"
            )
          )
        ), column(
          width = 6,
          bs4Card(
            title = " Plot",
            icon = icon("chart-pie"),
            status = "danger",
            solidHeader = FALSE,
            width = 12,
            plotOutput("plot_chrom_structure", height = "600px")
          )
        ), column(
          width = 3,
          bs4Card(
            title = "Plot chromosome structures and gene stats",
            status = "warning",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. App Name:"),
            br(),
            tags$b("plot_chrom_structure"),
            br(),br(),
            tags$b("2. Function Description"),
            br(),
            p("Plot chromosome structures and gene stats."),
            tags$b("3. Demo Output"),
            br(),br(),
            imageOutput("example_plot_chrom_structure", width = 300, height = NULL)
          ),
          bs4Card(
            title = "Example Datasets",
            status = "info",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. Genomic Annotation (GFF3/GTF)"),
            br(),
            tags$b("Mus musculus: GRCm39.115"),
            downloadButton("dl_gff_gtf_7", "Download GFF3", icon = icon("download")),
            br(), br(),
            tags$b("2. Differentially expressed genes (DESeq2)"),
            br(),

            downloadButton("dl_deg_deg_7", "Download DEG", icon = icon("download")),
            br(), br(),
            tags$b("3. Differentially methylated regions (MethylKit)"),
            br(),

            downloadButton("dl_dmr_dmg_7", "Download DMR", icon = icon("download")),
            br(), br(),
            tags$b("4. SNP mutation site (VCFtools)"),
            br(),

            downloadButton("dl_fst_snp_7", "Download SNP", icon = icon("download"))
          )
        )
      )),

      bs4TabItem(tabName = "plot_chrom_genes", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = " Parameters",
            icon = icon("gear"),
            status = "info",
            solidHeader = FALSE,
            width = 12,
            actionButton(
              inputId = "run_plot_chrom_genes",
              label = "Run",
              icon = icon("circle-play"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "download_plot_chrom_genes",
              label = "Download",
              icon = icon("cloud-arrow-down"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "session_download_plot_chrom_genes",
              label = "Version, Parameter, MD5",
              icon = icon("circle-info"),
              style = "width: 100%",
              class = "btn-block"
            ),
            br(),
            fileInput(inputId = "gff_file_chrom_genes", label = "GFF/GTF file"),
            selectInput(
              inputId = "gff_format_chrom_genes",
              label = "Format",
              choices = c("auto", "gff3", "gtf"),
              selected = "auto"
            ),
            fileInput(inputId = "gene_table_file", label = "Gene table (2 cols: id,name)"),
            selectInput(
              inputId = "annotate_mode",
              label = "Annotate",
              choices = c("id", "name"),
              selected = "id"
            ),
            selectInput(
              inputId = "chrom_genes_orientation",
              label = "Orientation",
              choices = c("vertical", "horizontal"),
              selected = "vertical"
            ),
            sliderInput(
              inputId = "min_gap_frac",
              label = "Min gap frac",
              min = 0.005,
              max = 0.1,
              value = 0.02,
              step = 0.005
            ),
            sliderInput(
              inputId = "bar_width_genes",
              label = "Bar width",
              min = 0.1,
              max = 1,
              value = 0.6,
              step = 0.05
            ),
            sliderInput(
              inputId = "chrom_alpha_genes",
              label = "Chrom alpha",
              min = 0,
              max = 1,
              value = 0.1,
              step = 0.05
            ),
            sliderInput(
              inputId = "gene_width_genes",
              label = "Gene width",
              min = 0.1,
              max = 1,
              value = 0.5,
              step = 0.05
            ),
            textInput(
              inputId = "chrom_color_genes",
              label = "Chrom color",
              value = "#008888"
            ),
            textInput(
              inputId = "gene_color_genes",
              label = "Gene color",
              value = "#0088ff"
            ),
            textInput(
              inputId = "telomere_color_genes",
              label = "Telomere color",
              value = "#ff0000"
            ),
            numericInput(
              inputId = "label_size_genes",
              label = "Label size",
              value = 3,
              min = 1,
              step = 1
            ),
            numericInput(
              inputId = "connector_dx1_genes",
              label = "Connector dx1",
              value = 0.2,
              min = 0,
              step = 0.05
            ),
            numericInput(
              inputId = "connector_dx2_genes",
              label = "Connector dx2",
              value = 0.2,
              min = 0,
              step = 0.05
            ),
            numericInput(
              inputId = "plot_width_chrom_genes",
              label = "Width (in)",
              value = 10,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_height_chrom_genes",
              label = "Height (in)",
              value = 6,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_dpi_chrom_genes",
              label = "DPI",
              value = 300,
              min = 72,
              step = 10
            ),
            selectInput(
              inputId = "plot_format_chrom_genes",
              label = "Format",
              choices = c("pdf", "jpeg"),
              selected = "pdf"
            )
          )
        ), column(
          width = 6,
          bs4Card(
            title = " Plot",
            icon = icon("chart-pie"),
            status = "danger",
            solidHeader = FALSE,
            width = 12,
            plotOutput("plot_chrom_genes", height = "600px")
          )
        ), column(
          width = 3,
          bs4Card(
            title = "Plot chromosome structures and gene annotation",
            status = "warning",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. App Name:"),
            br(),
            tags$b("plot_chrom_genes"),
            br(),br(),
            tags$b("2. Function Description"),
            br(),
            p("Plot chromosome structures and gene annotation."),
            tags$b("3. Demo Output"),
            br(),br(),
            imageOutput("example_plot_chrom_genes", width = 300, height = NULL)
          ),
          bs4Card(
            title = "Example Datasets",
            status = "info",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. Genomic Annotation (GFF3/GTF)"),
            br(),
            tags$b("Mus musculus: GRCm39.115"),
            downloadButton("dl_gff_gtf_8", "Download GFF3", icon = icon("download")),
            br(), br(),
            tags$b("2. Differentially expressed genes (DESeq2)"),
            br(),

            downloadButton("dl_deg_deg_8", "Download DEG", icon = icon("download")),
            br(), br(),
            tags$b("3. Differentially methylated regions (MethylKit)"),
            br(),

            downloadButton("dl_dmr_dmg_8", "Download DMR", icon = icon("download")),
            br(), br(),
            tags$b("4. SNP mutation site (VCFtools)"),
            br(),

            downloadButton("dl_fst_snp_8", "Download SNP", icon = icon("download"))
          )
        )
      )),

      bs4TabItem(tabName = "plot_chrom_heatmap", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = " Parameters",
            icon = icon("gear"),
            status = "info",
            solidHeader = FALSE,
            width = 12,
            actionButton(
              inputId = "run_plot_chrom_heatmap",
              label = "Run",
              icon = icon("circle-play"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "download_plot_chrom_heatmap",
              label = "Download",
              icon = icon("cloud-arrow-down"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "session_download_plot_chrom_heatmap",
              label = "Version, Parameter, MD5",
              icon = icon("circle-info"),
              style = "width: 100%",
              class = "btn-block"
            ),
            br(),
            fileInput(inputId = "gff_file_heatmap", label = "GFF/GTF file"),
            selectInput(
              inputId = "gff_format_heatmap",
              label = "Format",
              choices = c("auto", "gff3", "gtf"),
              selected = "auto"
            ),
            selectInput(
              inputId = "feature_type",
              label = "Feature",
              choices = c("gene", "exon", "CDS", "promoter"),
              selected = "gene"
            ),
            numericInput(
              inputId = "bin_size_heatmap",
              label = "Bin size",
              value = 1e6,
              min = 1e4,
              step = 1e5
            ),
            selectInput(
              inputId = "orientation_heatmap",
              label = "Orientation",
              choices = c("horizontal", "vertical"),
              selected = "horizontal"
            ),
            textInput(
              inputId = "palette_start",
              label = "Palette start",
              value = "#ffffff"
            ),
            textInput(
              inputId = "palette_end",
              label = "Palette end",
              value = "#0055aa"
            ),
            sliderInput(
              inputId = "alpha_heatmap",
              label = "Alpha",
              min = 0,
              max = 1,
              value = 0.9,
              step = 0.05
            ),
            numericInput(
              inputId = "plot_width_chrom_heatmap",
              label = "Width (in)",
              value = 10,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_height_chrom_heatmap",
              label = "Height (in)",
              value = 6,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_dpi_chrom_heatmap",
              label = "DPI",
              value = 300,
              min = 72,
              step = 10
            ),
            selectInput(
              inputId = "plot_format_chrom_heatmap",
              label = "Format",
              choices = c("pdf", "jpeg"),
              selected = "pdf"
            )
          )
        ), column(
          width = 6,
          bs4Card(
            title = " Plot",
            icon = icon("chart-pie"),
            status = "danger",
            solidHeader = FALSE,
            width = 12,
            plotOutput("plot_chrom_heatmap", height = "600px")
          )
        ), column(
          width = 3,
          bs4Card(
            title = "Plot genomic feature density heatmap",
            status = "warning",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. App Name:"),
            br(),
            tags$b("plot_chrom_heatmap"),
            br(),br(),
            tags$b("2. Function Description"),
            br(),
            p("Plot genomic feature density heatmap."),
            tags$b("3. Demo Output"),
            br(),br(),
            imageOutput("example_plot_chrom_heatmap", width = 300, height = NULL)
          ),
          bs4Card(
            title = "Example Datasets",
            status = "info",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. Genomic Annotation (GFF3/GTF)"),
            br(),
            tags$b("Mus musculus: GRCm39.115"),
            downloadButton("dl_gff_gtf_9", "Download GFF3", icon = icon("download")),
            br(), br(),
            tags$b("2. Differentially expressed genes (DESeq2)"),
            br(),

            downloadButton("dl_deg_deg_9", "Download DEG", icon = icon("download")),
            br(), br(),
            tags$b("3. Differentially methylated regions (MethylKit)"),
            br(),

            downloadButton("dl_dmr_dmg_9", "Download DMR", icon = icon("download")),
            br(), br(),
            tags$b("4. SNP mutation site (VCFtools)"),
            br(),

            downloadButton("dl_fst_snp_9", "Download SNP", icon = icon("download"))
          )
        )
      )),

      bs4TabItem(tabName = "plot_deg_chrom", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = " Parameters",
            icon = icon("gear"),
            status = "info",
            solidHeader = FALSE,
            width = 12,
            actionButton(
              inputId = "run_plot_deg_chrom",
              label = "Run",
              icon = icon("circle-play"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "download_plot_deg_chrom",
              label = "Download",
              icon = icon("cloud-arrow-down"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "session_download_plot_deg_chrom",
              label = "Version, Parameter, MD5",
              icon = icon("circle-info"),
              style = "width: 100%",
              class = "btn-block"
            ),
            br(),
            fileInput(inputId = "deg_file", label = "DEG table"),
            fileInput(inputId = "gff_file_deg", label = "GFF/GTF file"),
            selectInput(
              inputId = "gff_format_deg",
              label = "Format",
              choices = c("auto", "gff3", "gtf"),
              selected = "auto"
            ),
            textInput(
              inputId = "id_col",
              label = "ID column",
              value = "GeneID"
            ),
            textInput(
              inputId = "fc_col",
              label = "FC column",
              value = "log2FoldChange"
            ),
            selectInput(
              inputId = "violin_scale",
              label = "Violin scale",
              choices = c("count", "area", "width"),
              selected = "count"
            ),
            sliderInput(
              inputId = "violin_border",
              label = "Violin border",
              min = 0,
              max = 2,
              value = 0.5,
              step = 0.1
            ),
            numericInput(
              inputId = "point_shape_deg",
              label = "Point shape",
              value = 16,
              min = 0,
              step = 1
            ),
            numericInput(
              inputId = "point_size_deg",
              label = "Point size",
              value = 2,
              min = 0.5,
              step = 0.5
            ),
            sliderInput(
              inputId = "jitter_width_deg",
              label = "Jitter width",
              min = 0,
              max = 1,
              value = 0.2,
              step = 0.05
            ),
            textInput(
              inputId = "hyper_color_deg",
              label = "Hyper color",
              value = "#ff000088"
            ),
            textInput(
              inputId = "hypo_color_deg",
              label = "Hypo color",
              value = "#00880088"
            ),
            numericInput(
              inputId = "plot_width_deg_chrom",
              label = "Width (in)",
              value = 10,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_height_deg_chrom",
              label = "Height (in)",
              value = 6,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_dpi_deg_chrom",
              label = "DPI",
              value = 300,
              min = 72,
              step = 10
            ),
            selectInput(
              inputId = "plot_format_deg_chrom",
              label = "Format",
              choices = c("pdf", "jpeg"),
              selected = "pdf"
            )
          )
        ), column(
          width = 6,
          bs4Card(
            title = " Plot",
            icon = icon("chart-pie"),
            status = "danger",
            solidHeader = FALSE,
            width = 12,
            plotOutput("plot_deg_chrom", height = "600px")
          )
        ), column(
          width = 3,
          bs4Card(
            title = "Plot DEGs hyper/hypo distributions",
            status = "warning",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. App Name:"),
            br(),
            tags$b("plot_deg_chrom"),
            br(),br(),
            tags$b("2. Function Description"),
            br(),
            p("Plot differentially expressed genes (DEGs) hyper/hypo distributions by chromosomes."),
            tags$b("3. Demo Output"),
            br(),br(),
            imageOutput("example_plot_deg_chrom", width = 300, height = NULL)
          ),
          bs4Card(
            title = "Example Datasets",
            status = "info",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. Genomic Annotation (GFF3/GTF)"),
            br(),
            tags$b("Mus musculus: GRCm39.115"),
            downloadButton("dl_gff_gtf_10", "Download GFF3", icon = icon("download")),
            br(), br(),
            tags$b("2. Differentially expressed genes (DESeq2)"),
            br(),

            downloadButton("dl_deg_deg_10", "Download DEG", icon = icon("download")),
            br(), br(),
            tags$b("3. Differentially methylated regions (MethylKit)"),
            br(),

            downloadButton("dl_dmr_dmg_10", "Download DMR", icon = icon("download")),
            br(), br(),
            tags$b("4. SNP mutation site (VCFtools)"),
            br(),

            downloadButton("dl_fst_snp_10", "Download SNP", icon = icon("download"))
          )
        )
      )),

      bs4TabItem(tabName = "plot_deg_exp", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = " Parameters",
            icon = icon("gear"),
            status = "info",
            solidHeader = FALSE,
            width = 12,
            actionButton(
              inputId = "run_plot_deg_exp",
              label = "Run",
              icon = icon("circle-play"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "download_plot_deg_exp",
              label = "Download",
              icon = icon("cloud-arrow-down"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "session_download_plot_deg_exp",
              label = "Version, Parameter, MD5",
              icon = icon("circle-info"),
              style = "width: 100%",
              class = "btn-block"
            ),
            br(),
            fileInput(inputId = "deg_file_exp", label = "DEG table"),
            fileInput(inputId = "gff_file_deg_exp", label = "GFF/GTF file"),
            selectInput(
              inputId = "gff_format_deg_exp",
              label = "Format",
              choices = c("auto", "gff3", "gtf"),
              selected = "auto"
            ),
            textInput(
              inputId = "id_col_exp",
              label = "ID column",
              value = "GeneID"
            ),
            textInput(
              inputId = "fc_col_exp",
              label = "FC column",
              value = "log2FoldChange"
            ),
            selectInput(
              inputId = "orientation_deg_exp",
              label = "Orientation",
              choices = c("horizontal", "vertical"),
              selected = "horizontal"
            ),
            sliderInput(
              inputId = "chrom_alpha_deg_exp",
              label = "Chrom alpha",
              min = 0,
              max = 1,
              value = 0.1,
              step = 0.05
            ),
            numericInput(
              inputId = "bar_height_deg_exp",
              label = "Bar height",
              value = 0.8,
              min = 0.1,
              step = 0.1
            ),
            textInput(
              inputId = "chrom_color_deg_exp",
              label = "Chrom color",
              value = "#008888"
            ),
            numericInput(
              inputId = "point_size_deg_exp",
              label = "Point size",
              value = 1,
              min = 0.5,
              step = 0.5
            ),
            sliderInput(
              inputId = "point_alpha_deg_exp",
              label = "Point alpha",
              min = 0,
              max = 1,
              value = 0.3,
              step = 0.05
            ),
            textInput(
              inputId = "up_color_deg_exp",
              label = "Up color",
              value = "#ff0000"
            ),
            textInput(
              inputId = "down_color_deg_exp",
              label = "Down color",
              value = "#008800"
            ),
            selectInput(
              inputId = "mark_style_deg_exp",
              label = "Mark style",
              choices = c("point", "line"),
              selected = "point"
            ),
            numericInput(
              inputId = "line_width_deg_exp",
              label = "Line width",
              value = 0.6,
              min = 0.1,
              step = 0.1
            ),
            numericInput(
              inputId = "line_height_deg_exp",
              label = "Line height",
              value = 0.8,
              min = 0.1,
              step = 0.1
            ),
            numericInput(
              inputId = "plot_width_deg_exp",
              label = "Width (in)",
              value = 10,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_height_deg_exp",
              label = "Height (in)",
              value = 6,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_dpi_deg_exp",
              label = "DPI",
              value = 300,
              min = 72,
              step = 10
            ),
            selectInput(
              inputId = "plot_format_deg_exp",
              label = "Format",
              choices = c("pdf", "jpeg"),
              selected = "pdf"
            )
          )
        ), column(
          width = 6,
          bs4Card(
            title = " Plot",
            icon = icon("chart-pie"),
            status = "danger",
            solidHeader = FALSE,
            width = 12,
            plotOutput("plot_deg_exp", height = "600px")
          )
        ), column(
          width = 3,
          bs4Card(
            title = "Plot DEGs up/down along chromosomes",
            status = "warning",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. App Name:"),
            br(),
            tags$b("plot_deg_exp"),
            br(),br(),
            tags$b("2. Function Description"),
            br(),
            p("Plot DEGs up/down along chromosomes."),
            tags$b("3. Demo Output"),
            br(),br(),
            imageOutput("example_plot_deg_exp", width = 300, height = NULL)
          ),
          bs4Card(
            title = "Example Datasets",
            status = "info",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. Genomic Annotation (GFF3/GTF)"),
            br(),
            tags$b("Mus musculus: GRCm39.115"),
            downloadButton("dl_gff_gtf_11", "Download GFF3", icon = icon("download")),
            br(), br(),
            tags$b("2. Differentially expressed genes (DESeq2)"),
            br(),

            downloadButton("dl_deg_deg_11", "Download DEG", icon = icon("download")),
            br(), br(),
            tags$b("3. Differentially methylated regions (MethylKit)"),
            br(),

            downloadButton("dl_dmr_dmg_11", "Download DMR", icon = icon("download")),
            br(), br(),
            tags$b("4. SNP mutation site (VCFtools)"),
            br(),

            downloadButton("dl_fst_snp_11", "Download SNP", icon = icon("download"))
          )
        )
      )),

      bs4TabItem(tabName = "plot_deg_volcano", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = " Parameters",
            icon = icon("gear"),
            status = "info",
            solidHeader = FALSE,
            width = 12,
            actionButton(
              inputId = "run_plot_deg_volcano",
              label = "Run",
              icon = icon("circle-play"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "download_plot_deg_volcano",
              label = "Download",
              icon = icon("cloud-arrow-down"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "session_download_plot_deg_volcano",
              label = "Version, Parameter, MD5",
              icon = icon("circle-info"),
              style = "width: 100%",
              class = "btn-block"
            ),
            br(),
            fileInput(inputId = "deg_file_volcano", label = "DEG table"),
            textInput(
              inputId = "id_col_volcano",
              label = "ID column",
              value = "GeneID"
            ),
            textInput(
              inputId = "fc_col_volcano",
              label = "FC column",
              value = "log2FoldChange"
            ),
            textInput(
              inputId = "sig_col_volcano",
              label = "Sig column",
              value = "padj"
            ),
            numericInput(
              inputId = "fc_threshold_volcano",
              label = "FC threshold",
              value = 1,
              min = 0,
              step = 0.1
            ),
            numericInput(
              inputId = "sig_threshold_volcano",
              label = "Sig threshold",
              value = 0.05,
              min = 0,
              max = 1,
              step = 0.01
            ),
            numericInput(
              inputId = "point_size_volcano",
              label = "Point size",
              value = 1.5,
              min = 0.5,
              step = 0.5
            ),
            sliderInput(
              inputId = "point_alpha_volcano",
              label = "Point alpha",
              min = 0,
              max = 1,
              value = 0.6,
              step = 0.05
            ),
            textInput(
              inputId = "up_color_volcano",
              label = "Up color",
              value = "#ff0000"
            ),
            textInput(
              inputId = "down_color_volcano",
              label = "Down color",
              value = "#008800"
            ),
            textInput(
              inputId = "ns_color_volcano",
              label = "NS color",
              value = "#999999"
            ),
            numericInput(
              inputId = "plot_width_deg_volcano",
              label = "Width (in)",
              value = 10,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_height_deg_volcano",
              label = "Height (in)",
              value = 6,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_dpi_deg_volcano",
              label = "DPI",
              value = 300,
              min = 72,
              step = 10
            ),
            selectInput(
              inputId = "plot_format_deg_volcano",
              label = "Format",
              choices = c("pdf", "jpeg"),
              selected = "pdf"
            )
          )
        ), column(
          width = 6,
          bs4Card(
            title = " Plot",
            icon = icon("chart-pie"),
            status = "danger",
            solidHeader = FALSE,
            width = 12,
            plotOutput("plot_deg_volcano", height = "600px")
          )
        ), column(
          width = 3,
          bs4Card(
            title = "Plot DEGs volcano",
            status = "warning",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. App Name:"),
            br(),
            tags$b("plot_deg_volcano"),
            br(),br(),
            tags$b("2. Function Description"),
            br(),
            p("Plot differentially expressed genes (DEGs) volcano."),
            tags$b("3. Demo Output"),
            br(),br(),
            imageOutput("example_plot_deg_volcano", width = 300, height = NULL)
          ),
          bs4Card(
            title = "Example Datasets",
            status = "info",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. Genomic Annotation (GFF3/GTF)"),
            br(),
            tags$b("Mus musculus: GRCm39.115"),
            downloadButton("dl_gff_gtf_12", "Download GFF3", icon = icon("download")),
            br(), br(),
            tags$b("2. Differentially expressed genes (DESeq2)"),
            br(),

            downloadButton("dl_deg_deg_12", "Download DEG", icon = icon("download")),
            br(), br(),
            tags$b("3. Differentially methylated regions (MethylKit)"),
            br(),

            downloadButton("dl_dmr_dmg_12", "Download DMR", icon = icon("download")),
            br(), br(),
            tags$b("4. SNP mutation site (VCFtools)"),
            br(),

            downloadButton("dl_fst_snp_12", "Download SNP", icon = icon("download"))
          )
        )
      )),

      bs4TabItem(tabName = "plot_snp_fst", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = " Parameters",
            icon = icon("gear"),
            status = "info",
            solidHeader = FALSE,
            width = 12,
            actionButton(
              inputId = "run_plot_snp_fst",
              label = "Run",
              icon = icon("circle-play"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "download_plot_snp_fst",
              label = "Download",
              icon = icon("cloud-arrow-down"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "session_download_plot_snp_fst",
              label = "Version, Parameter, MD5",
              icon = icon("circle-info"),
              style = "width: 100%",
              class = "btn-block"
            ),
            br(),
            fileInput(inputId = "fst_file_heat", label = "FST table"),
            numericInput(
              inputId = "bin_size_fst",
              label = "Bin size",
              value = 1e6,
              min = 1e4,
              step = 1e5
            ),
            selectInput(
              inputId = "metric",
              label = "Metric",
              choices = c("fst_mean", "variant_count"),
              selected = "fst_mean"
            ),
            selectInput(
              inputId = "orientation_fst",
              label = "Orientation",
              choices = c("horizontal", "vertical"),
              selected = "horizontal"
            ),
            textInput(
              inputId = "palette_start_fst",
              label = "Palette start",
              value = "#ffffff"
            ),
            textInput(
              inputId = "palette_end_fst",
              label = "Palette end",
              value = "#aa00aa"
            ),
            sliderInput(
              inputId = "alpha_fst",
              label = "Alpha",
              min = 0,
              max = 1,
              value = 0.9,
              step = 0.05
            ),
            numericInput(
              inputId = "plot_width_snp_fst",
              label = "Width (in)",
              value = 10,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_height_snp_fst",
              label = "Height (in)",
              value = 6,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_dpi_snp_fst",
              label = "DPI",
              value = 300,
              min = 72,
              step = 10
            ),
            selectInput(
              inputId = "plot_format_snp_fst",
              label = "Format",
              choices = c("pdf", "jpeg"),
              selected = "pdf"
            )
          )
        ), column(
          width = 6,
          bs4Card(
            title = " Plot",
            icon = icon("chart-pie"),
            status = "danger",
            solidHeader = FALSE,
            width = 12,
            plotOutput("plot_snp_fst", height = "600px")
          )
        ), column(
          width = 3,
          bs4Card(
            title = "Plot genomic weighted FST heatmap",
            status = "warning",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. App Name:"),
            br(),
            tags$b("plot_snp_fst"),
            br(),br(),
            tags$b("2. Function Description"),
            br(),
            p("Plot genomic weighted FST heatmap."),
            tags$b("3. Demo Output"),
            br(),br(),
            imageOutput("example_plot_snp_fst", width = 300, height = NULL)
          ),
          bs4Card(
            title = "Example Datasets",
            status = "info",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. Genomic Annotation (GFF3/GTF)"),
            br(),
            tags$b("Mus musculus: GRCm39.115"),
            downloadButton("dl_gff_gtf_13", "Download GFF3", icon = icon("download")),
            br(), br(),
            tags$b("2. Differentially expressed genes (DESeq2)"),
            br(),

            downloadButton("dl_deg_deg_13", "Download DEG", icon = icon("download")),
            br(), br(),
            tags$b("3. Differentially methylated regions (MethylKit)"),
            br(),

            downloadButton("dl_dmr_dmg_13", "Download DMR", icon = icon("download")),
            br(), br(),
            tags$b("4. SNP mutation site (VCFtools)"),
            br(),

            downloadButton("dl_fst_snp_13", "Download SNP", icon = icon("download"))
          )
        )
      )),

      bs4TabItem(tabName = "plot_snp_anno", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = " Parameters",
            icon = icon("gear"),
            status = "info",
            solidHeader = FALSE,
            width = 12,
            actionButton(
              inputId = "run_plot_snp_anno",
              label = "Run",
              icon = icon("circle-play"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "download_plot_snp_anno",
              label = "Download",
              icon = icon("cloud-arrow-down"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "session_download_plot_snp_anno",
              label = "Version, Parameter, MD5",
              icon = icon("circle-info"),
              style = "width: 100%",
              class = "btn-block"
            ),
            br(),
            fileInput(inputId = "fst_file_anno", label = "FST table"),
            fileInput(inputId = "gff_file_fst", label = "GFF/GTF file"),
            selectInput(
              inputId = "gff_format_fst",
              label = "Format",
              choices = c("auto", "gff3", "gtf"),
              selected = "auto"
            ),
            textInput(
              inputId = "chrom_id_fst",
              label = "Chrom ID",
              value = "chr2"
            ),
            numericInput(
              inputId = "top_n",
              label = "Top N",
              value = 20,
              min = 1,
              step = 1
            ),
            selectInput(
              inputId = "orientation_fst_anno",
              label = "Orientation",
              choices = c("vertical", "horizontal"),
              selected = "vertical"
            ),
            sliderInput(
              inputId = "smooth_span",
              label = "Smooth span",
              min = 0.05,
              max = 1,
              value = 0.5,
              step = 0.05
            ),
            numericInput(
              inputId = "point_size_fst",
              label = "Point size",
              value = 1,
              min = 0.5,
              step = 0.5
            ),
            sliderInput(
              inputId = "point_alpha_fst",
              label = "Point alpha",
              min = 0,
              max = 1,
              value = 0.3,
              step = 0.05
            ),
            numericInput(
              inputId = "label_size_fst",
              label = "Label size",
              value = 3,
              min = 1,
              step = 1
            ),
            numericInput(
              inputId = "connector_dx1",
              label = "Connector dx1",
              value = 2e4,
              min = 0,
              step = 1e3
            ),
            numericInput(
              inputId = "connector_dx2",
              label = "Connector dx2",
              value = 4e4,
              min = 0,
              step = 1e3
            ),
            sliderInput(
              inputId = "gap_frac",
              label = "Gap frac",
              min = 0.01,
              max = 0.2,
              value = 0.05,
              step = 0.01
            ),
            textInput(
              inputId = "fst_color",
              label = "FST color",
              value = "#0088ff"
            ),
            numericInput(
              inputId = "plot_width_snp_anno",
              label = "Width (in)",
              value = 10,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_height_snp_anno",
              label = "Height (in)",
              value = 6,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_dpi_snp_anno",
              label = "DPI",
              value = 300,
              min = 72,
              step = 10
            ),
            selectInput(
              inputId = "plot_format_snp_anno",
              label = "Format",
              choices = c("pdf", "jpeg"),
              selected = "pdf"
            )
          )
        ), column(
          width = 6,
          bs4Card(
            title = " Plot",
            icon = icon("chart-pie"),
            status = "danger",
            solidHeader = FALSE,
            width = 12,
            plotOutput("plot_snp_anno", height = "600px")
          )
        ), column(
          width = 3,
          bs4Card(
            title = "Plot genomic FST with annotations",
            status = "warning",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. App Name:"),
            br(),
            tags$b("plot_snp_anno"),
            br(),br(),
            tags$b("2. Function Description"),
            br(),
            p("Plot genomic FST with Top-N gene annotations."),
            tags$b("3. Demo Output"),
            br(),br(),
            imageOutput("example_plot_snp_anno", width = 300, height = NULL)
          ),
          bs4Card(
            title = "Example Datasets",
            status = "info",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. Genomic Annotation (GFF3/GTF)"),
            br(),
            tags$b("Mus musculus: GRCm39.115"),
            downloadButton("dl_gff_gtf_14", "Download GFF3", icon = icon("download")),
            br(), br(),
            tags$b("2. Differentially expressed genes (DESeq2)"),
            br(),

            downloadButton("dl_deg_deg_14", "Download DEG", icon = icon("download")),
            br(), br(),
            tags$b("3. Differentially methylated regions (MethylKit)"),
            br(),

            downloadButton("dl_dmr_dmg_14", "Download DMR", icon = icon("download")),
            br(), br(),
            tags$b("4. SNP mutation site (VCFtools)"),
            br(),

            downloadButton("dl_fst_snp_14", "Download SNP", icon = icon("download"))
          )
        )
      )),

      bs4TabItem(tabName = "plot_dmg_chrom", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = " Parameters",
            icon = icon("gear"),
            status = "info",
            solidHeader = FALSE,
            width = 12,
            actionButton(
              inputId = "run_plot_dmg_chrom",
              label = "Run",
              icon = icon("circle-play"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "download_plot_dmg_chrom",
              label = "Download",
              icon = icon("cloud-arrow-down"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "session_download_plot_dmg_chrom",
              label = "Version, Parameter, MD5",
              icon = icon("circle-info"),
              style = "width: 100%",
              class = "btn-block"
            ),
            br(),
            fileInput(inputId = "dmr_file", label = "DMR table"),
            selectInput(
              inputId = "violin_scale_dmr",
              label = "Violin scale",
              choices = c("count", "area", "width"),
              selected = "count"
            ),
            sliderInput(
              inputId = "violin_border_dmr",
              label = "Violin border",
              min = 0,
              max = 2,
              value = 0.5,
              step = 0.1
            ),
            numericInput(
              inputId = "point_shape_dmr",
              label = "Point shape",
              value = 8,
              min = 0,
              step = 1
            ),
            numericInput(
              inputId = "point_size_dmr",
              label = "Point size",
              value = 2,
              min = 0.5,
              step = 0.5
            ),
            sliderInput(
              inputId = "jitter_width_dmr",
              label = "Jitter width",
              min = 0,
              max = 1,
              value = 0.2,
              step = 0.05
            ),
            textInput(
              inputId = "hyper_color_dmr",
              label = "Hyper color",
              value = "#ff880088"
            ),
            textInput(
              inputId = "hypo_color_dmr",
              label = "Hypo color",
              value = "#0088ff88"
            ),
            numericInput(
              inputId = "plot_width_dmg_chrom",
              label = "Width (in)",
              value = 10,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_height_dmg_chrom",
              label = "Height (in)",
              value = 6,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_dpi_dmg_chrom",
              label = "DPI",
              value = 300,
              min = 72,
              step = 10
            ),
            selectInput(
              inputId = "plot_format_dmg_chrom",
              label = "Format",
              choices = c("pdf", "jpeg"),
              selected = "pdf"
            )
          )
        ), column(
          width = 6,
          bs4Card(
            title = " Plot",
            icon = icon("chart-pie"),
            status = "danger",
            solidHeader = FALSE,
            width = 12,
            plotOutput("plot_dmg_chrom", height = "600px")
          )
        ), column(
          width = 3,
          bs4Card(
            title = "Plot DMRs hyper/hypo distributions",
            status = "warning",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. App Name:"),
            br(),
            tags$b("plot_dmg_chrom"),
            br(),br(),
            tags$b("2. Function Description"),
            br(),
            p("Plot differentially methylated regions (DMRs) hyper/hypo distributions by chromosome."),
            tags$b("3. Demo Output"),
            br(),br(),
            imageOutput("example_plot_dmg_chrom", width = 300, height = NULL)
          ),
          bs4Card(
            title = "Example Datasets",
            status = "info",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. Genomic Annotation (GFF3/GTF)"),
            br(),
            tags$b("Mus musculus: GRCm39.115"),
            downloadButton("dl_gff_gtf_15", "Download GFF3", icon = icon("download")),
            br(), br(),
            tags$b("2. Differentially expressed genes (DESeq2)"),
            br(),

            downloadButton("dl_deg_deg_15", "Download DEG", icon = icon("download")),
            br(), br(),
            tags$b("3. Differentially methylated regions (MethylKit)"),
            br(),

            downloadButton("dl_dmr_dmg_15", "Download DMR", icon = icon("download")),
            br(), br(),
            tags$b("4. SNP mutation site (VCFtools)"),
            br(),

            downloadButton("dl_fst_snp_15", "Download SNP", icon = icon("download"))
          )
        )
      )),
      bs4TabItem(tabName = "plot_dmg_exp", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = " Parameters",
            icon = icon("gear"),
            status = "info",
            solidHeader = FALSE,
            width = 12,
            actionButton(
              inputId = "run_plot_dmg_exp",
              label = "Run",
              icon = icon("circle-play"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "download_plot_dmg_exp",
              label = "Download",
              icon = icon("cloud-arrow-down"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "session_download_plot_dmg_exp",
              label = "Version, Parameter, MD5",
              icon = icon("circle-info"),
              style = "width: 100%",
              class = "btn-block"
            ),
            br(),
            fileInput(inputId = "dmr_file_exp", label = "DMR table"),
            selectInput(
              inputId = "orientation_dmg_exp",
              label = "Orientation",
              choices = c("horizontal", "vertical"),
              selected = "horizontal"
            ),
            sliderInput(
              inputId = "chrom_alpha_dmg_exp",
              label = "Chrom alpha",
              min = 0,
              max = 1,
              value = 0.1,
              step = 0.05
            ),
            numericInput(
              inputId = "bar_height_dmg_exp",
              label = "Bar height",
              value = 0.8,
              min = 0.1,
              step = 0.1
            ),
            textInput(
              inputId = "chrom_color_dmg_exp",
              label = "Chrom color",
              value = "#008888"
            ),
            numericInput(
              inputId = "point_size_dmg_exp",
              label = "Point size",
              value = 1,
              min = 0.5,
              step = 0.5
            ),
            sliderInput(
              inputId = "point_alpha_dmg_exp",
              label = "Point alpha",
              min = 0,
              max = 1,
              value = 0.3,
              step = 0.05
            ),
            textInput(
              inputId = "hyper_color_dmg_exp",
              label = "Hyper color",
              value = "#ff0000"
            ),
            textInput(
              inputId = "hypo_color_dmg_exp",
              label = "Hypo color",
              value = "#008800"
            ),
            selectInput(
              inputId = "mark_style_dmg_exp",
              label = "Mark style",
              choices = c("point", "line"),
              selected = "point"
            ),
            numericInput(
              inputId = "line_width_dmg_exp",
              label = "Line width",
              value = 0.6,
              min = 0.1,
              step = 0.1
            ),
            numericInput(
              inputId = "line_height_dmg_exp",
              label = "Line height",
              value = 0.8,
              min = 0.1,
              step = 0.1
            ),
            numericInput(
              inputId = "plot_width_dmg_exp",
              label = "Width (in)",
              value = 10,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_height_dmg_exp",
              label = "Height (in)",
              value = 6,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_dpi_dmg_exp",
              label = "DPI",
              value = 300,
              min = 72,
              step = 10
            ),
            selectInput(
              inputId = "plot_format_dmg_exp",
              label = "Format",
              choices = c("pdf", "jpeg"),
              selected = "pdf"
            )
          )
        ), column(
          width = 6,
          bs4Card(
            title = " Plot",
            icon = icon("chart-pie"),
            status = "danger",
            solidHeader = FALSE,
            width = 12,
            plotOutput("plot_dmg_exp", height = "600px")
          )
        ), column(
          width = 3,
          bs4Card(
            title = "Plot DMGs hyper/hypo along chromosomes",
            status = "warning",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. App Name:"),
            br(),
            tags$b("plot_dmg_exp"),
            br(),br(),
            tags$b("2. Function Description"),
            br(),
            p("Plot DMGs hyper/hypo along chromosomes."),
            tags$b("3. Demo Output"),
            br(),br(),
            imageOutput("example_plot_dmg_exp", width = 300, height = NULL)
          ),
          bs4Card(
            title = "Example Datasets",
            status = "info",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. Genomic Annotation (GFF3/GTF)"),
            br(),
            tags$b("Mus musculus: GRCm39.115"),
            downloadButton("dl_gff_gtf_16", "Download GFF3", icon = icon("download")),
            br(), br(),
            tags$b("2. Differentially expressed genes (DESeq2)"),
            br(),

            downloadButton("dl_deg_deg_16", "Download DEG", icon = icon("download")),
            br(), br(),
            tags$b("3. Differentially methylated regions (MethylKit)"),
            br(),

            downloadButton("dl_dmr_dmg_16", "Download DMR", icon = icon("download")),
            br(), br(),
            tags$b("4. SNP mutation site (VCFtools)"),
            br(),

            downloadButton("dl_fst_snp_16", "Download SNP", icon = icon("download"))
          )
        )
      ))
      ,
      bs4TabItem(tabName = "plot_gene_stats", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = " Parameters",
            icon = icon("gear"),
            status = "info",
            solidHeader = FALSE,
            width = 12,
            actionButton(
              inputId = "run_plot_gene_stats",
              label = "Run",
              icon = icon("circle-play"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "download_plot_gene_stats",
              label = "Download",
              icon = icon("cloud-arrow-down"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "session_download_plot_gene_stats",
              label = "Version, Parameter, MD5",
              icon = icon("circle-info"),
              style = "width: 100%",
              class = "btn-block"
            ),
            br(),
            fileInput(inputId = "gff_file_gene_stats", label = "GFF/GTF file"),
            selectInput(
              inputId = "gff_format_gene_stats",
              label = "Format",
              choices = c("auto", "gff3", "gtf"),
              selected = "auto"
            ),
            sliderInput(
              inputId = "bar_width_gene_stats",
              label = "Bar width",
              min = 0.1,
              max = 1,
              value = 0.7,
              step = 0.05
            ),
            textInput(
              inputId = "bar_color_gene_stats",
              label = "Bar color",
              value = "#0055ff55"
            ),
            numericInput(
              inputId = "label_size_gene_stats",
              label = "Label size",
              value = 3,
              min = 1,
              step = 1
            ),
            numericInput(
              inputId = "plot_width_gene_stats",
              label = "Width (in)",
              value = 10,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_height_gene_stats",
              label = "Height (in)",
              value = 6,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_dpi_gene_stats",
              label = "DPI",
              value = 300,
              min = 72,
              step = 10
            ),
            selectInput(
              inputId = "plot_format_gene_stats",
              label = "Format",
              choices = c("pdf", "jpeg"),
              selected = "pdf"
            )
          )
        ), column(
          width = 6,
          bs4Card(
            title = " Plot",
            icon = icon("chart-pie"),
            status = "danger",
            solidHeader = FALSE,
            width = 12,
            plotOutput("plot_gene_stats", height = "600px")
          )
        ), column(
          width = 3,
          bs4Card(
            title = "Plot gene stats",
            status = "warning",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. App Name:"),
            br(),
            tags$b("plot_gene_stats"),
            br(),br(),
            tags$b("2. Function Description"),
            br(),
            p("Plot gene stats for chromosomes."),
            tags$b("3. Demo Output"),
            br(),br(),
            imageOutput("example_plot_gene_stats", width = 300, height = NULL)
          ),
          bs4Card(
            title = "Example Datasets",
            status = "info",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. Genomic Annotation (GFF3/GTF)"),
            br(),
            tags$b("Mus musculus: GRCm39.115"),
            downloadButton("dl_gff_gtf_17", "Download GFF3", icon = icon("download")),
            br(), br(),
            tags$b("2. Differentially expressed genes (DESeq2)"),
            br(),

            downloadButton("dl_deg_deg_17", "Download DEG", icon = icon("download")),
            br(), br(),
            tags$b("3. Differentially methylated regions (MethylKit)"),
            br(),

            downloadButton("dl_dmr_dmg_17", "Download DMR", icon = icon("download")),
            br(), br(),
            tags$b("4. SNP mutation site (VCFtools)"),
            br(),

            downloadButton("dl_fst_snp_17", "Download SNP", icon = icon("download"))
          )
        )
      )),
      bs4TabItem(tabName = "plot_snp_density", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = " Parameters",
            icon = icon("gear"),
            status = "info",
            solidHeader = FALSE,
            width = 12,
            actionButton(
              inputId = "run_plot_snp_density",
              label = "Run",
              icon = icon("circle-play"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "download_plot_snp_density",
              label = "Download",
              icon = icon("cloud-arrow-down"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "session_download_plot_snp_density",
              label = "Version, Parameter, MD5",
              icon = icon("circle-info"),
              style = "width: 100%",
              class = "btn-block"
            ),
            br(),
            fileInput(inputId = "fst_file_density", label = "FST table"),
            checkboxInput(
              inputId = "log10_density",
              label = "LOG10",
              value = FALSE
            ),
            numericInput(
              inputId = "bin_size_density",
              label = "Bin size",
              value = 1e6,
              min = 1e4,
              step = 1e5
            ),
            textInput(
              inputId = "density_color1",
              label = "Density color 1",
              value = "#0088ff"
            ),
            textInput(
              inputId = "density_color2",
              label = "Density color 2",
              value = "#ff8800"
            ),
            textInput(
              inputId = "density_color3",
              label = "Density color 3",
              value = "#ff0000"
            ),
            numericInput(
              inputId = "plot_width_snp_density",
              label = "Width (in)",
              value = 10,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_height_snp_density",
              label = "Height (in)",
              value = 6,
              min = 1,
              step = 0.5
            ),
            numericInput(
              inputId = "plot_dpi_snp_density",
              label = "DPI",
              value = 300,
              min = 72,
              step = 10
            ),
            selectInput(
              inputId = "plot_format_snp_density",
              label = "Format",
              choices = c("pdf", "jpeg"),
              selected = "pdf"
            )
          )
        ), column(
          width = 6,
          bs4Card(
            title = " Plot",
            icon = icon("chart-pie"),
            status = "danger",
            solidHeader = FALSE,
            width = 12,
            plotOutput("plot_snp_density", height = "600px")
          )
        ), column(
          width = 3,
          bs4Card(
            title = "Plot SNP density",
            status = "warning",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. App Name:"),
            br(),
            tags$b("plot_snp_density"),
            br(),br(),
            tags$b("2. Function Description"),
            br(),
            p("Plot SNP density at chromosome level."),
            tags$b("3. Demo Output"),
            br(),br(),
            imageOutput("example_plot_snp_density", width = 300, height = NULL)
          ),
          bs4Card(
            title = "Example Datasets",
            status = "info",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. Genomic Annotation (GFF3/GTF)"),
            br(),
            tags$b("Mus musculus: GRCm39.115"),
            downloadButton("dl_gff_gtf_18", "Download GFF3", icon = icon("download")),
            br(), br(),
            tags$b("2. Differentially expressed genes (DESeq2)"),
            br(),

            downloadButton("dl_deg_deg_18", "Download DEG", icon = icon("download")),
            br(), br(),
            tags$b("3. Differentially methylated regions (MethylKit)"),
            br(),

            downloadButton("dl_dmr_dmg_18", "Download DMR", icon = icon("download")),
            br(), br(),
            tags$b("4. SNP mutation site (VCFtools)"),
            br(),

            downloadButton("dl_fst_snp_18", "Download SNP", icon = icon("download"))
          )
        )
      )),
      bs4TabItem(tabName = "anno_fst_dmr", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = " Parameters",
            icon = icon("gear"),
            status = "info",
            solidHeader = FALSE,
            width = 12,
            actionButton(
              inputId = "run_anno_fst_dmr",
              label = "Run",
              icon = icon("circle-play"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "download_table_anno_fst_dmr",
              label = "Download",
              icon = icon("cloud-arrow-down"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "session_download_table_anno_fst_dmr",
              label = "Version, Parameter, MD5",
              icon = icon("circle-info"),
              style = "width: 100%",
              class = "btn-block"
            ),
            br(),
            fileInput(inputId = "gff_file_anno_ranges", label = "GFF/GTF file"),
            selectInput(
              inputId = "gff_format_anno_ranges",
              label = "Format",
              choices = c("auto", "gff3", "gtf"),
              selected = "auto"
            ),
            fileInput(inputId = "genomic_ranges_file", label = "Genomic ranges (FST/DMR)"),
            textInput(
              inputId = "chrom_col_ranges",
              label = "Chrom column",
              value = "CHROM"
            ),
            textInput(
              inputId = "start_col_ranges",
              label = "Start column",
              value = "BIN_START"
            ),
            textInput(
              inputId = "end_col_ranges",
              label = "End column",
              value = "BIN_END"
            ),
            numericInput(
              inputId = "upstream_ranges",
              label = "Promoter upstream",
              value = 2000,
              min = 0,
              step = 100
            ),
            numericInput(
              inputId = "downstream_ranges",
              label = "Promoter downstream",
              value = 200,
              min = 0,
              step = 50
            ),
            checkboxInput(
              inputId = "ignore_strand_ranges",
              label = "Ignore strand",
              value = TRUE
            ),
            selectInput(
              inputId = "features_ranges",
              label = "Features",
              multiple = TRUE,
              choices = c(
                "promoter",
                "UTR5",
                "gene",
                "exon",
                "intron",
                "CDS",
                "UTR3",
                "intergenic"
              ),
              selected = c("promoter", "UTR5", "gene", "exon", "intron", "CDS", "UTR3")
            )
          )
        ), column(
          width = 6,
          bs4Card(
            title = "Data",
            status = "primary",
            solidHeader = FALSE,
            width = 12,
            DT::dataTableOutput("table_anno_fst_dmr")
          )
        ), column(
          width = 3,
          bs4Card(
            title = "Annotate FST/DMR",
            status = "warning",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. App Name:"),
            br(),
            tags$b("anno_fst_dmr"),
            br(),br(),
            tags$b("2. Function Description"),
            br(),
            p("Annotate FST/DMR windows with genomic features."),
            tags$b("3. Demo Output"),
            br(),br(),
            imageOutput("example_anno_fst_dmr", width = 300, height = NULL)
          ),
          bs4Card(
            title = "Example Datasets",
            status = "info",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. Genomic Annotation (GFF3/GTF)"),
            br(),
            tags$b("Mus musculus: GRCm39.115"),
            downloadButton("dl_gff_gtf_19", "Download GFF3", icon = icon("download")),
            br(), br(),
            tags$b("2. Differentially expressed genes (DESeq2)"),
            br(),

            downloadButton("dl_deg_deg_19", "Download DEG", icon = icon("download")),
            br(), br(),
            tags$b("3. Differentially methylated regions (MethylKit)"),
            br(),

            downloadButton("dl_dmr_dmg_19", "Download DMR", icon = icon("download")),
            br(), br(),
            tags$b("4. SNP mutation site (VCFtools)"),
            br(),

            downloadButton("dl_fst_snp_19", "Download SNP", icon = icon("download"))
          )
        )
      )),
      bs4TabItem(tabName = "extract_promoters", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = " Parameters",
            icon = icon("gear"),
            status = "info",
            solidHeader = FALSE,
            width = 12,
            actionButton(
              inputId = "run_extract_promoters",
              label = "Run",
              icon = icon("circle-play"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "download_table_extract_promoters",
              label = "Download",
              icon = icon("cloud-arrow-down"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "session_download_table_extract_promoters",
              label = "Version, Parameter, MD5",
              icon = icon("circle-info"),
              style = "width: 100%",
              class = "btn-block"
            ),
            br(),
            fileInput(inputId = "gff_file_extract_promoters", label = "GFF/GTF file"),
            selectInput(
              inputId = "gff_format_extract_promoters",
              label = "Format",
              choices = c("auto", "gff3", "gtf"),
              selected = "auto"
            ),
            numericInput(
              inputId = "upstream_extract_promoters",
              label = "Promoter upstream",
              value = 2000,
              min = 0,
              step = 100
            ),
            numericInput(
              inputId = "downstream_extract_promoters",
              label = "Promoter downstream",
              value = 200,
              min = 0,
              step = 50
            ),
            selectInput(
              inputId = "promoter_info",
              label = "Info",
              choices = c("all", "chrom_id", "promoter_id", "promoter_range"),
              selected = "all"
            )
          )
        ), column(
          width = 6,
          bs4Card(
            title = "Data",
            status = "primary",
            solidHeader = FALSE,
            width = 12,
            DT::dataTableOutput("table_extract_promoters")
          )
        ), column(
          width = 3,
          bs4Card(
            title = "Extract promoter ranges",
            status = "warning",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. App Name:"),
            br(),
            tags$b("extract_promoters"),
            br(),br(),
            tags$b("2. Function Description"),
            br(),
            p("Extract promoter ranges from GFF or GTF."),
            tags$b("3. Demo Output"),
            br(),br(),
            imageOutput("example_extract_promoters", width = 300, height = NULL)
          ),
          bs4Card(
            title = "Example Datasets",
            status = "info",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. Genomic Annotation (GFF3/GTF)"),
            br(),
            tags$b("Mus musculus: GRCm39.115"),
            downloadButton("dl_gff_gtf_20", "Download GFF3", icon = icon("download")),
            br(), br(),
            tags$b("2. Differentially expressed genes (DESeq2)"),
            br(),

            downloadButton("dl_deg_deg_20", "Download DEG", icon = icon("download")),
            br(), br(),
            tags$b("3. Differentially methylated regions (MethylKit)"),
            br(),

            downloadButton("dl_dmr_dmg_20", "Download DMR", icon = icon("download")),
            br(), br(),
            tags$b("4. SNP mutation site (VCFtools)"),
            br(),

            downloadButton("dl_fst_snp_20", "Download SNP", icon = icon("download"))
          )
        )
      )),
      bs4TabItem(tabName = "extract_utr5", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = " Parameters",
            icon = icon("gear"),
            status = "info",
            solidHeader = FALSE,
            width = 12,
            actionButton(
              inputId = "run_extract_utr5",
              label = "Run",
              icon = icon("circle-play"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "download_table_extract_utr5",
              label = "Download",
              icon = icon("cloud-arrow-down"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "session_download_table_extract_utr5",
              label = "Version, Parameter, MD5",
              icon = icon("circle-info"),
              style = "width: 100%",
              class = "btn-block"
            ),
            br(),
            fileInput(inputId = "gff_file_extract_utr5", label = "GFF/GTF file"),
            selectInput(
              inputId = "gff_format_extract_utr5",
              label = "Format",
              choices = c("auto", "gff3", "gtf"),
              selected = "auto"
            ),
            selectInput(
              inputId = "utr5_info",
              label = "Info",
              choices = c("all", "chrom_id", "utr5_range"),
              selected = "all"
            )
          )
        ), column(
          width = 6,
          bs4Card(
            title = "Data",
            status = "primary",
            solidHeader = FALSE,
            width = 12,
            DT::dataTableOutput("table_extract_utr5")
          )
        ), column(
          width = 3,
          bs4Card(
            title = "Extract 5'UTR ranges",
            status = "warning",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. App Name:"),
            br(),
            tags$b("extract_utr5"),
            br(),br(),
            tags$b("2. Function Description"),
            br(),
            p("Extract 5'UTR ranges from GFF or GTF."),
            tags$b("3. Demo Output"),
            br(),br(),
            imageOutput("example_extract_utr5", width = 300, height = NULL)
          ),
          bs4Card(
            title = "Example Datasets",
            status = "info",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. Genomic Annotation (GFF3/GTF)"),
            br(),
            tags$b("Mus musculus: GRCm39.115"),
            downloadButton("dl_gff_gtf_21", "Download GFF3", icon = icon("download")),
            br(), br(),
            tags$b("2. Differentially expressed genes (DESeq2)"),
            br(),

            downloadButton("dl_deg_deg_21", "Download DEG", icon = icon("download")),
            br(), br(),
            tags$b("3. Differentially methylated regions (MethylKit)"),
            br(),

            downloadButton("dl_dmr_dmg_21", "Download DMR", icon = icon("download")),
            br(), br(),
            tags$b("4. SNP mutation site (VCFtools)"),
            br(),

            downloadButton("dl_fst_snp_21", "Download SNP", icon = icon("download"))
          )
        )
      )),
      bs4TabItem(tabName = "extract_genes", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = " Parameters",
            icon = icon("gear"),
            status = "info",
            solidHeader = FALSE,
            width = 12,
            actionButton(
              inputId = "run_extract_genes",
              label = "Run",
              icon = icon("circle-play"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "download_table_extract_genes",
              label = "Download",
              icon = icon("cloud-arrow-down"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "session_download_table_extract_genes",
              label = "Version, Parameter, MD5",
              icon = icon("circle-info"),
              style = "width: 100%",
              class = "btn-block"
            ),
            br(),
            fileInput(inputId = "gff_file_extract_genes", label = "GFF/GTF file"),
            selectInput(
              inputId = "gff_format_extract_genes",
              label = "Format",
              choices = c("auto", "gff3", "gtf"),
              selected = "auto"
            ),
            selectInput(
              inputId = "gene_info_opt",
              label = "Info",
              choices = c("all", "chrom_id", "gene_id", "gene_range"),
              selected = "all"
            )
          )
        ), column(
          width = 6,
          bs4Card(
            title = "Data",
            status = "primary",
            solidHeader = FALSE,
            width = 12,
            DT::dataTableOutput("table_extract_genes")
          )
        ), column(
          width = 3,
          bs4Card(
            title = "Extract genes information",
            status = "warning",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. App Name:"),
            br(),
            tags$b("extract_genes"),
            br(),br(),
            tags$b("2. Function Description"),
            br(),
            p("Extract genes information from GFF or GTF."),
            tags$b("3. Demo Output"),
            br(),br(),
            imageOutput("example_extract_genes", width = 300, height = NULL)
          ),
          bs4Card(
            title = "Example Datasets",
            status = "info",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. Genomic Annotation (GFF3/GTF)"),
            br(),
            tags$b("Mus musculus: GRCm39.115"),
            downloadButton("dl_gff_gtf_22", "Download GFF3", icon = icon("download")),
            br(), br(),
            tags$b("2. Differentially expressed genes (DESeq2)"),
            br(),

            downloadButton("dl_deg_deg_22", "Download DEG", icon = icon("download")),
            br(), br(),
            tags$b("3. Differentially methylated regions (MethylKit)"),
            br(),

            downloadButton("dl_dmr_dmg_22", "Download DMR", icon = icon("download")),
            br(), br(),
            tags$b("4. SNP mutation site (VCFtools)"),
            br(),

            downloadButton("dl_fst_snp_22", "Download SNP", icon = icon("download"))
          )
        )
      )),
      bs4TabItem(tabName = "extract_mrnas", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = " Parameters",
            icon = icon("gear"),
            status = "info",
            solidHeader = FALSE,
            width = 12,
            actionButton(
              inputId = "run_extract_mrnas",
              label = "Run",
              icon = icon("circle-play"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "download_table_extract_mrnas",
              label = "Download",
              icon = icon("cloud-arrow-down"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "session_download_table_extract_mrnas",
              label = "Version, Parameter, MD5",
              icon = icon("circle-info"),
              style = "width: 100%",
              class = "btn-block"
            ),
            br(),
            fileInput(inputId = "gff_file_extract_mrnas", label = "GFF/GTF file"),
            selectInput(
              inputId = "gff_format_extract_mrnas",
              label = "Format",
              choices = c("auto", "gff3", "gtf"),
              selected = "auto"
            ),
            selectInput(
              inputId = "mrna_info_opt",
              label = "Info",
              choices = c("all", "chrom_id", "mrna_id", "mrna_range"),
              selected = "all"
            )
          )
        ), column(
          width = 6,
          bs4Card(
            title = "Data",
            status = "primary",
            solidHeader = FALSE,
            width = 12,
            DT::dataTableOutput("table_extract_mrnas")
          )
        ), column(
          width = 3,
          bs4Card(
            title = "Extract mRNA ranges",
            status = "warning",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. App Name:"),
            br(),
            tags$b("extract_mrnas"),
            br(),br(),
            tags$b("2. Function Description"),
            br(),
            p("Extract mRNA ranges from GFF or GTF."),
            tags$b("3. Demo Output"),
            br(),br(),
            imageOutput("example_extract_mrnas", width = 300, height = NULL)
          ),
          bs4Card(
            title = "Example Datasets",
            status = "info",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. Genomic Annotation (GFF3/GTF)"),
            br(),
            tags$b("Mus musculus: GRCm39.115"),
            downloadButton("dl_gff_gtf_23", "Download GFF3", icon = icon("download")),
            br(), br(),
            tags$b("2. Differentially expressed genes (DESeq2)"),
            br(),

            downloadButton("dl_deg_deg_23", "Download DEG", icon = icon("download")),
            br(), br(),
            tags$b("3. Differentially methylated regions (MethylKit)"),
            br(),

            downloadButton("dl_dmr_dmg_23", "Download DMR", icon = icon("download")),
            br(), br(),
            tags$b("4. SNP mutation site (VCFtools)"),
            br(),

            downloadButton("dl_fst_snp_23", "Download SNP", icon = icon("download"))
          )
        )
      )),
      bs4TabItem(tabName = "extract_cds", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = " Parameters",
            icon = icon("gear"),
            status = "info",
            solidHeader = FALSE,
            width = 12,
            actionButton(
              inputId = "run_extract_cds",
              label = "Run",
              icon = icon("circle-play"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "download_table_extract_cds",
              label = "Download",
              icon = icon("cloud-arrow-down"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "session_download_table_extract_cds",
              label = "Version, Parameter, MD5",
              icon = icon("circle-info"),
              style = "width: 100%",
              class = "btn-block"
            ),
            br(),
            fileInput(inputId = "gff_file_extract_cds", label = "GFF/GTF file"),
            selectInput(
              inputId = "gff_format_extract_cds",
              label = "Format",
              choices = c("auto", "gff3", "gtf"),
              selected = "auto"
            ),
            selectInput(
              inputId = "cds_info_opt",
              label = "Info",
              choices = c("all", "chrom_id", "cds_id", "cds_range"),
              selected = "all"
            )
          )
        ), column(
          width = 6,
          bs4Card(
            title = "Data",
            status = "primary",
            solidHeader = FALSE,
            width = 12,
            DT::dataTableOutput("table_extract_cds")
          )
        ), column(
          width = 3,
          bs4Card(
            title = "Extract CDS ranges",
            status = "warning",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. App Name:"),
            br(),
            tags$b("extract_cds"),
            br(),br(),
            tags$b("2. Function Description"),
            br(),
            p("Extract CDS ranges from GFF or GTF."),
            tags$b("3. Demo Output"),
            br(),br(),
            imageOutput("example_extract_cds", width = 300, height = NULL)
          ),
          bs4Card(
            title = "Example Datasets",
            status = "info",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. Genomic Annotation (GFF3/GTF)"),
            br(),
            tags$b("Mus musculus: GRCm39.115"),
            downloadButton("dl_gff_gtf_24", "Download GFF3", icon = icon("download")),
            br(), br(),
            tags$b("2. Differentially expressed genes (DESeq2)"),
            br(),

            downloadButton("dl_deg_deg_24", "Download DEG", icon = icon("download")),
            br(), br(),
            tags$b("3. Differentially methylated regions (MethylKit)"),
            br(),

            downloadButton("dl_dmr_dmg_24", "Download DMR", icon = icon("download")),
            br(), br(),
            tags$b("4. SNP mutation site (VCFtools)"),
            br(),

            downloadButton("dl_fst_snp_24", "Download SNP", icon = icon("download"))
          )
        )
      )),
      bs4TabItem(tabName = "extract_exons", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = " Parameters",
            icon = icon("gear"),
            status = "info",
            solidHeader = FALSE,
            width = 12,
            actionButton(
              inputId = "run_extract_exons",
              label = "Run",
              icon = icon("circle-play"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "download_table_extract_exons",
              label = "Download",
              icon = icon("cloud-arrow-down"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "session_download_table_extract_exons",
              label = "Version, Parameter, MD5",
              icon = icon("circle-info"),
              style = "width: 100%",
              class = "btn-block"
            ),
            br(),
            fileInput(inputId = "gff_file_extract_exons", label = "GFF/GTF file"),
            selectInput(
              inputId = "gff_format_extract_exons",
              label = "Format",
              choices = c("auto", "gff3", "gtf"),
              selected = "auto"
            ),
            selectInput(
              inputId = "exon_info_opt",
              label = "Info",
              choices = c("all", "chrom_id", "exon_id", "exon_range"),
              selected = "all"
            )
          )
        ), column(
          width = 6,
          bs4Card(
            title = "Data",
            status = "primary",
            solidHeader = FALSE,
            width = 12,
            DT::dataTableOutput("table_extract_exons")
          )
        ), column(
          width = 3,
          bs4Card(
            title = "Extract Exons ranges",
            status = "warning",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. App Name:"),
            br(),
            tags$b("extract_exons"),
            br(),br(),
            tags$b("2. Function Description"),
            br(),
            p("Extract Exons ranges from GFF or GTF."),
            tags$b("3. Demo Output"),
            br(),br(),
            imageOutput("example_extract_exons", width = 300, height = NULL)
          ),
          bs4Card(
            title = "Example Datasets",
            status = "info",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. Genomic Annotation (GFF3/GTF)"),
            br(),
            tags$b("Mus musculus: GRCm39.115"),
            downloadButton("dl_gff_gtf_25", "Download GFF3", icon = icon("download")),
            br(), br(),
            tags$b("2. Differentially expressed genes (DESeq2)"),
            br(),

            downloadButton("dl_deg_deg_25", "Download DEG", icon = icon("download")),
            br(), br(),
            tags$b("3. Differentially methylated regions (MethylKit)"),
            br(),

            downloadButton("dl_dmr_dmg_25", "Download DMR", icon = icon("download")),
            br(), br(),
            tags$b("4. SNP mutation site (VCFtools)"),
            br(),

            downloadButton("dl_fst_snp_25", "Download SNP", icon = icon("download"))
          )
        )
      )),
      bs4TabItem(tabName = "extract_utr3", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = " Parameters",
            icon = icon("gear"),
            status = "info",
            solidHeader = FALSE,
            width = 12,
            actionButton(
              inputId = "run_extract_utr3",
              label = "Run",
              icon = icon("circle-play"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "download_table_extract_utr3",
              label = "Download",
              icon = icon("cloud-arrow-down"),
              style = "width: 100%",
              class = "btn-block"
            ),
            downloadButton(
              outputId = "session_download_table_extract_utr3",
              label = "Version, Parameter, MD5",
              icon = icon("circle-info"),
              style = "width: 100%",
              class = "btn-block"
            ),
            br(),
            fileInput(inputId = "gff_file_extract_utr3", label = "GFF/GTF file"),
            selectInput(
              inputId = "gff_format_extract_utr3",
              label = "Format",
              choices = c("auto", "gff3", "gtf"),
              selected = "auto"
            ),
            selectInput(
              inputId = "utr3_info_opt",
              label = "Info",
              choices = c("all", "chrom_id", "utr3_range"),
              selected = "all"
            )
          )
        ), column(
          width = 6,
          bs4Card(
            title = "Data",
            status = "primary",
            solidHeader = FALSE,
            width = 12,
            DT::dataTableOutput("table_extract_utr3")
          )
        ), column(
          width = 3,
          bs4Card(
            title = "Extract 3'UTR ranges",
            status = "warning",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. App Name:"),
            br(),
            tags$b("extract_utr3"),
            br(),br(),
            tags$b("2. Function Description"),
            br(),
            p("Extract 3'UTR ranges from GFF or GTF."),
            tags$b("3. Demo Output"),
            br(),br(),
            imageOutput("example_extract_utr3", width = 300, height = NULL)
          ),
          bs4Card(
            title = "Example Datasets",
            status = "info",
            solidHeader = FALSE,
            collapsible = FALSE,
            width = 12,
            style = "height: 390px; overflow-y: auto;",
            tags$b("1. Genomic Annotation (GFF3/GTF)"),
            br(),
            tags$b("Mus musculus: GRCm39.115"),
            downloadButton("dl_gff_gtf_26", "Download GFF3", icon = icon("download")),
            br(), br(),
            tags$b("2. Differentially expressed genes (DESeq2)"),
            br(),

            downloadButton("dl_deg_deg_26", "Download DEG", icon = icon("download")),
            br(), br(),
            tags$b("3. Differentially methylated regions (MethylKit)"),
            br(),

            downloadButton("dl_dmr_dmg_26", "Download DMR", icon = icon("download")),
            br(), br(),
            tags$b("4. SNP mutation site (VCFtools)"),
            br(),

            downloadButton("dl_fst_snp_26", "Download SNP", icon = icon("download"))
          )
        )
      ))
    )
  )
)

server <- function(input, output, session) {
  observeEvent(TRUE, {
    updateTabItems(session, "main_menu", "plot_interval_structure")
  }, ignoreInit = FALSE, once = TRUE)

  getGff <- function(infile) {
    if (!is.null(infile))
      infile$datapath
    else
      system.file("extdata", "example.gff3.gz", package = "GAnnoViz")
  }
  getDeg <- function(infile) {
    if (!is.null(infile))
      infile$datapath
    else
      system.file("extdata", "example.deg", package = "GAnnoViz")
  }
  getFst <- function(infile) {
    if (!is.null(infile))
      infile$datapath
    else
      system.file("extdata", "example.fst", package = "GAnnoViz")
  }
  getDmr <- function(infile) {
    if (!is.null(infile))
      infile$datapath
    else
      system.file("extdata", "example.dmr", package = "GAnnoViz")
  }
  readGeneTable <- function(infile) {
    if (is.null(infile)) {
      data.frame(
        gene_id = c("ENSMUSG00000042414", "ENSMUSG00000025935", "ENSMUSG00000048701", "ENSMUSG00000035385"),
        gene_name = c("Prdm14", "Tram1", "Ccdc6", "Ccl2"),
        stringsAsFactors = FALSE
      )
    } else {
      utils::read.table(
        infile$datapath,
        header = TRUE,
        sep = "\t",
        stringsAsFactors = FALSE,
        check.names = FALSE
      )
    }
  }
  grToDf <- function(gr) {
    if (is.null(gr))
      return(data.frame())
    data.frame(
      chrom = as.character(GenomicRanges::seqnames(gr)),
      start = BiocGenerics::start(gr),
      end = BiocGenerics::end(gr),
      as.data.frame(S4Vectors::mcols(gr)),
      stringsAsFactors = FALSE
    )
  }

  output$example_plot_gene_structure <- renderImage({
    p <- exampleImageFile("plot_gene_structure")
    list(src = p, contentType = "image/png", alt = "plot_gene_structure", width = 320)
  }, deleteFile = FALSE)
  output$example_plot_interval_structure <- renderImage({
    p <- exampleImageFile("plot_interval_structure")
    list(src = p, contentType = "image/png", alt = "plot_interval_structure", width = 320)
  }, deleteFile = FALSE)
  output$example_plot_interval_flank <- renderImage({
    p <- exampleImageFile("plot_interval_flank")
    list(src = p, contentType = "image/png", alt = "plot_interval_flank", width = 320)
  }, deleteFile = FALSE)
  output$example_plot_chrom_structure <- renderImage({
    p <- exampleImageFile("plot_chrom_structure")
    list(src = p, contentType = "image/png", alt = "plot_chrom_structure", width = 320)
  }, deleteFile = FALSE)
  output$example_plot_chrom_genes <- renderImage({
    p <- exampleImageFile("plot_chrom_genes")
    list(src = p, contentType = "image/png", alt = "plot_chrom_genes", width = 320)
  }, deleteFile = FALSE)
  output$example_plot_chrom_heatmap <- renderImage({
    p <- exampleImageFile("plot_chrom_heatmap")
    list(src = p, contentType = "image/png", alt = "plot_chrom_heatmap", width = 320)
  }, deleteFile = FALSE)
  output$example_plot_gene_domains <- renderImage({
    p <- exampleImageFile("plot_gene_domains")
    list(src = p, contentType = "image/png", alt = "plot_gene_domains", width = 320)
  }, deleteFile = FALSE)
  output$example_plot_gene_stats <- renderImage({
    p <- exampleImageFile("plot_gene_stats")
    list(src = p, contentType = "image/png", alt = "plot_gene_stats", width = 320)
  }, deleteFile = FALSE)
  output$example_plot_deg_exp <- renderImage({
    p <- exampleImageFile("plot_deg_exp")
    list(src = p, contentType = "image/png", alt = "plot_deg_exp", width = 320)
  }, deleteFile = FALSE)
  output$example_plot_snp_density <- renderImage({
    p <- exampleImageFile("plot_snp_density")
    list(src = p, contentType = "image/png", alt = "plot_snp_density", width = 320)
  }, deleteFile = FALSE)
  output$example_plot_dmg_trend <- renderImage({
    p <- exampleImageFile("plot_dmg_trend")
    list(src = p, contentType = "image/png", alt = "plot_dmg_trend", width = 320)
  }, deleteFile = FALSE)

  output$example_anno_deg_chrom <- renderImage({
    p <- exampleImageFile("plot_deg_chrom")
    list(src = p, contentType = "image/png", alt = "anno_deg_chrom", width = 320)
  }, deleteFile = FALSE)
  output$example_plot_deg_chrom <- renderImage({
    p <- exampleImageFile("plot_deg_chrom")
    list(src = p, contentType = "image/png", alt = "plot_deg_chrom", width = 320)
  }, deleteFile = FALSE)
  output$example_plot_deg_volcano <- renderImage({
    p <- exampleImageFile("plot_deg_volcano")
    list(src = p, contentType = "image/png", alt = "plot_deg_volcano", width = 320)
  }, deleteFile = FALSE)
  output$example_plot_dmg_chrom <- renderImage({
    p <- exampleImageFile("plot_dmg_chrom")
    list(src = p, contentType = "image/png", alt = "plot_dmg_chrom", width = 320)
  }, deleteFile = FALSE)
  output$example_plot_dmg_exp <- renderImage({
    p <- exampleImageFile("plot_dmg_exp")
    list(src = p, contentType = "image/png", alt = "plot_dmg_exp", width = 320)
  }, deleteFile = FALSE)
  output$example_anno_fst_dmr <- renderImage({
    p <- exampleImageFile("plot_dmg_manhattan")
    list(src = p, contentType = "image/png", alt = "anno_fst_dmr", width = 320)
  }, deleteFile = FALSE)
  output$example_plot_snp_anno <- renderImage({
    p <- exampleImageFile("plot_snp_anno")
    list(src = p, contentType = "image/png", alt = "plot_snp_anno", width = 320)
  }, deleteFile = FALSE)
  output$example_plot_snp_fst <- renderImage({
    p <- exampleImageFile("plot_snp_fst")
    list(src = p, contentType = "image/png", alt = "plot_snp_fst", width = 320)
  }, deleteFile = FALSE)
  output$example_extract_cds <- renderImage({
    p <- placeholderImage()
    list(src = p, contentType = "image/png", alt = "extract_cds", width = 320)
  }, deleteFile = FALSE)
  output$example_extract_exons <- renderImage({
    p <- placeholderImage()
    list(src = p, contentType = "image/png", alt = "extract_exons", width = 320)
  }, deleteFile = FALSE)
  output$example_extract_genes <- renderImage({
    p <- placeholderImage()
    list(src = p, contentType = "image/png", alt = "extract_genes", width = 320)
  }, deleteFile = FALSE)
  output$example_extract_mrnas <- renderImage({
    p <- placeholderImage()
    list(src = p, contentType = "image/png", alt = "extract_mrnas", width = 320)
  }, deleteFile = FALSE)
  output$example_extract_promoters <- renderImage({
    p <- placeholderImage()
    list(src = p, contentType = "image/png", alt = "extract_promoters", width = 320)
  }, deleteFile = FALSE)
  output$example_extract_utr3 <- renderImage({
    p <- placeholderImage()
    list(src = p, contentType = "image/png", alt = "extract_utr3", width = 320)
  }, deleteFile = FALSE)
  output$example_extract_utr5 <- renderImage({
    p <- placeholderImage()
    list(src = p, contentType = "image/png", alt = "extract_utr5", width = 320)
  }, deleteFile = FALSE)


  lapply(1:26, function(i) {
    output[[paste0("dl_gff_gtf_", i)]] <- downloadHandler(
      filename = function() "example.gff3.gz",
      content = function(file) file.copy(sample_gff(), file, overwrite = TRUE)
    )
    output[[paste0("dl_deg_deg_", i)]] <- downloadHandler(
      filename = function() "example.deg",
      content = function(file) file.copy(sample_deg(), file, overwrite = TRUE)
    )
    output[[paste0("dl_fst_snp_", i)]] <- downloadHandler(
      filename = function() "example.fst",
      content = function(file) file.copy(sample_fst(), file, overwrite = TRUE)
    )
    output[[paste0("dl_dmr_dmg_", i)]] <- downloadHandler(
      filename = function() "example.dmr",
      content = function(file) file.copy(sample_dmr(), file, overwrite = TRUE)
    )
  })

    param_map <- list(
  "download_plot_gene_structure" = c("arrow_count", "arrow_length", "arrow_unit", "downstream", "exon_color", "feature_alpha", "gene_id", "gff_file_gene", "gff_format_gene", "intron_color", "intron_width", "promoter_color", "upstream", "utr3_color", "utr5_color", "x_breaks"),
  "download_table_anno_deg_chrom" = c("deg_file_anno", "fc_col_anno", "gff_file_deg_anno", "gff_format_deg_anno", "id_col_anno", "upstream_anno", "downstream_anno"),
  "download_plot_gene_domains" = c("gene_name_domains", "legend_ncol_domains", "palette_domains", "species_domains", "transcript_choice_domains", "transcript_id_domains"),
  "download_plot_dmg_trend" = c("chrom_id_trend", "dmr_file_trend", "hyper_color_trend", "hypo_color_trend", "point_alpha_trend", "point_size_trend", "smooth_span_trend"),
  "download_plot_interval_structure" = c("arrow_count_interval", "arrow_length_interval", "arrow_unit_interval", "chrom_id", "downstream_interval", "exon_color_interval", "feature_alpha_interval", "gff_file_interval", "gff_format_interval", "intron_color_interval", "intron_width_interval", "promoter_color_interval", "upstream_interval", "utr3_color_interval", "utr5_color_interval", "win_end", "win_start", "x_breaks_interval"),
  "download_plot_interval_flank" = c("arrow_length_flank", "arrow_unit_flank", "downstream_flank", "flank_downstream", "flank_gene_id", "flank_upstream", "gene_color_flank", "gff_file_flank", "gff_format_flank", "label_size_flank", "promoter_color_flank", "show_promoters", "upstream_flank"),
  "download_plot_chrom_structure" = c("bar_width", "chrom_alpha", "chrom_color", "chrom_orientation", "gene_color_chrom", "gene_width", "gff_file_chrom", "gff_format_chrom", "label_size_chrom", "telomere_color"),
  "download_plot_chrom_genes" = c("annotate_mode", "bar_width_genes", "chrom_alpha_genes", "chrom_color_genes", "chrom_genes_orientation", "connector_dx1_genes", "connector_dx2_genes", "gene_color_genes", "gene_table_file", "gene_width_genes", "gff_file_chrom_genes", "gff_format_chrom_genes", "label_size_genes", "min_gap_frac", "telomere_color_genes"),
  "download_plot_chrom_heatmap" = c("alpha_heatmap", "bin_size_heatmap", "feature_type", "gff_file_heatmap", "gff_format_heatmap", "orientation_heatmap", "palette_end", "palette_start"),
  "download_plot_deg_chrom" = c("deg_file", "fc_col", "gff_file_deg", "gff_format_deg", "hyper_color_deg", "hypo_color_deg", "id_col", "jitter_width_deg", "point_shape_deg", "point_size_deg", "violin_border", "violin_scale"),
  "download_plot_deg_exp" = c("bar_height_deg_exp", "chrom_alpha_deg_exp", "chrom_color_deg_exp", "deg_file_exp", "down_color_deg_exp", "fc_col_exp", "gff_file_deg_exp", "gff_format_deg_exp", "id_col_exp", "line_height_deg_exp", "line_width_deg_exp", "mark_style_deg_exp", "orientation_deg_exp", "point_alpha_deg_exp", "point_size_deg_exp", "up_color_deg_exp"),
  "download_plot_deg_volcano" = c("deg_file_volcano", "down_color_volcano", "fc_col_volcano", "fc_threshold_volcano", "id_col_volcano", "ns_color_volcano", "point_alpha_volcano", "point_size_volcano", "sig_col_volcano", "sig_threshold_volcano", "up_color_volcano"),
  "download_plot_snp_fst" = c("alpha_fst", "bin_size_fst", "fst_file_heat", "metric", "orientation_fst", "palette_end_fst", "palette_start_fst"),
  "download_plot_snp_anno" = c("chrom_id_fst", "connector_dx1", "connector_dx2", "fst_color", "fst_file_anno", "gap_frac", "gff_file_fst", "gff_format_fst", "label_size_fst", "orientation_fst_anno", "point_alpha_fst", "point_size_fst", "smooth_span", "top_n"),
  "download_plot_dmg_chrom" = c("dmr_file", "hyper_color_dmr", "hypo_color_dmr", "jitter_width_dmr", "point_shape_dmr", "point_size_dmr", "violin_border_dmr", "violin_scale_dmr"),
  "download_plot_dmg_exp" = c("bar_height_dmg_exp", "chrom_alpha_dmg_exp", "chrom_color_dmg_exp", "dmr_file_exp", "hyper_color_dmg_exp", "hypo_color_dmg_exp", "line_height_dmg_exp", "line_width_dmg_exp", "mark_style_dmg_exp", "orientation_dmg_exp", "point_alpha_dmg_exp", "point_size_dmg_exp"),
  "download_plot_gene_stats" = c("bar_color_gene_stats", "bar_width_gene_stats", "gff_file_gene_stats", "gff_format_gene_stats", "label_size_gene_stats"),
  "download_plot_snp_density" = c("bin_size_density", "density_color1", "density_color2", "density_color3", "fst_file_density", "log10_density"),
  "download_table_anno_fst_dmr" = c("chrom_col_ranges", "downstream_ranges", "end_col_ranges", "features_ranges", "genomic_ranges_file", "gff_file_anno_ranges", "gff_format_anno_ranges", "ignore_strand_ranges", "start_col_ranges", "upstream_ranges"),
  "download_table_extract_promoters" = c("downstream_extract_promoters", "gff_file_extract_promoters", "gff_format_extract_promoters", "promoter_info", "upstream_extract_promoters"),
  "download_table_extract_utr5" = c("gff_file_extract_utr5", "gff_format_extract_utr5", "utr5_info"),
  "download_table_extract_genes" = c("gene_info_opt", "gff_file_extract_genes", "gff_format_extract_genes"),
  "download_table_extract_mrnas" = c("gff_file_extract_mrnas", "gff_format_extract_mrnas", "mrna_info_opt"),
  "download_table_extract_cds" = c("cds_info_opt", "gff_file_extract_cds", "gff_format_extract_cds"),
  "download_table_extract_exons" = c("exon_info_opt", "gff_file_extract_exons", "gff_format_extract_exons"),
  "download_table_extract_utr3" = c("gff_file_extract_utr3", "gff_format_extract_utr3", "utr3_info_opt")
  )
  lapply(names(param_map), function(id) {
    output[[paste0("session_", id)]] <- downloadHandler(
      filename = function() "sessionInfo.txt",
      content = function(file) {
        # 1. Version, Parameter, MD5
        si <- capture.output(sessionInfo())

        # 2. Parameters & 3. Files
        params <- character(0)
        files <- character(0)

        input_ids <- param_map[[id]]
        for (iid in input_ids) {
          val <- input[[iid]]
          if (is.null(val)) next

          if (is.data.frame(val) && "datapath" %in% names(val)) {
            # File input
            # Calculate MD5
            md5 <- tools::md5sum(val$datapath)
            files <- c(files, sprintf("%s: %s (MD5: %s)", iid, val$name, md5))
          } else {
            # Regular parameter
            # Convert vector to string if needed
            val_str <- paste(val, collapse = ", ")
            params <- c(params, sprintf("%s: %s", iid, val_str))
          }
        }

        # Combine sections
        out_text <- c(
          "=== Version, Parameter, MD5 ===",
          si,
          "",
          "=== Parameter Configuration ===",
          if (length(params) > 0) params else "No parameters detected.",
          "",
          "=== File Checksums ===",
          if (length(files) > 0) files else "No files uploaded."
        )

        writeLines(out_text, file)
      }
    )
  })

  dfGeneFeatures <- function(gff_file,
                             format,
                             gene_id,
                             upstream,
                             downstream) {
    txdb <- suppressWarnings(txdbmaker::makeTxDbFromGFF(file = gff_file, format = format))
    genes <- suppressWarnings(GenomicFeatures::genes(txdb))
    if (!(gene_id %in% genes$gene_id))
      return(data.frame())
    exons_by_tx <- suppressWarnings(GenomicFeatures::exonsBy(txdb, by = "tx"))
    introns_by_tx <- suppressWarnings(GenomicFeatures::intronsByTranscript(txdb, use.names = TRUE))
    utr5_by_tx <- suppressWarnings(GenomicFeatures::fiveUTRsByTranscript(txdb, use.names = TRUE))
    utr3_by_tx <- suppressWarnings(GenomicFeatures::threeUTRsByTranscript(txdb, use.names = TRUE))
    promoters_tx <- suppressWarnings(
      GenomicFeatures::promoters(
        txdb,
        upstream = upstream,
        downstream = downstream,
        use.names = TRUE
      )
    )
    tx_by_gene <- suppressWarnings(GenomicFeatures::transcriptsBy(txdb, by = "gene"))
    tx_names <- if (gene_id %in% names(tx_by_gene))
      tx_by_gene[[gene_id]]$tx_name
    else
      character(0)
    build_df <- function(gr_list, feature) {
      if (is.null(gr_list) || length(gr_list) == 0)
        return(data.frame())
      lst <- split(gr_list, gr_list$tx_name)
      lst <- lst[names(lst) %in% tx_names]
      if (length(lst) == 0)
        return(data.frame())
      dfs <- lapply(names(lst), function(nm) {
        gr <- lst[[nm]]
        data.frame(
          tx_name = nm,
          feature = feature,
          start = BiocGenerics::start(gr),
          end = BiocGenerics::end(gr),
          strand = as.character(GenomicRanges::strand(gr)),
          stringsAsFactors = FALSE
        )
      })
      do.call(rbind, dfs)
    }
    df <- do.call(rbind,
                  list(
                    build_df(exons_by_tx, "exon"),
                    build_df(introns_by_tx, "intron"),
                    build_df(utr5_by_tx, "utr5"),
                    build_df(utr3_by_tx, "utr3"),
                    build_df(promoters_tx, "promoter")
                  ))
    df
  }

  plot_gene_structure_ev <- eventReactive(input$run_plot_gene_structure, {
    plot_gene_structure(
      gff_file = getGff(input$gff_file_gene),
      format = input$gff_format_gene,
      gene_id = input$gene_id,
      upstream = input$upstream,
      downstream = input$downstream,
      feature_alpha = input$feature_alpha,
      intron_width = input$intron_width,
      x_breaks = input$x_breaks,
      arrow_length = input$arrow_length,
      arrow_count = input$arrow_count,
      arrow_unit = input$arrow_unit,
      promoter_color = input$promoter_color,
      utr5_color = input$utr5_color,
      utr3_color = input$utr3_color,
      exon_color = input$exon_color,
      intron_color = input$intron_color
    )
  })
  output$plot_gene_structure <- renderPlot({
    req(plot_gene_structure_ev())
    print(plot_gene_structure_ev())
  })
  output$download_plot_gene_structure <- downloadHandler(
    filename = function() {
      fmt <- input$plot_format_gene_structure
      sprintf("plot_gene_structure.%s", fmt)
    },
    content = function(file) {
      p <- plot_gene_structure_ev()
      req(p)
      ggplot2::ggsave(
        filename = file,
        plot = p,
        width = input$plot_width_gene_structure,
        height = input$plot_height_gene_structure,
        dpi = input$plot_dpi_gene_structure,
        device = input$plot_format_gene_structure
      )
    }
  )

  plot_interval_structure_ev <- eventReactive(input$run_plot_interval_structure, {
    plot_interval_structure(
      gff_file = getGff(input$gff_file_interval),
      format = input$gff_format_interval,
      chrom_id = input$chrom_id,
      start = input$win_start,
      end = input$win_end,
      x_breaks = input$x_breaks_interval,
      upstream = input$upstream_interval,
      downstream = input$downstream_interval,
      feature_alpha = input$feature_alpha_interval,
      intron_width = input$intron_width_interval,
      arrow_length = input$arrow_length_interval,
      arrow_count = input$arrow_count_interval,
      arrow_unit = input$arrow_unit_interval,
      promoter_color = input$promoter_color_interval,
      utr5_color = input$utr5_color_interval,
      utr3_color = input$utr3_color_interval,
      exon_color = input$exon_color_interval,
      intron_color = input$intron_color_interval
    )
  })
  output$plot_interval_structure <- renderPlot({
    req(plot_interval_structure_ev())
    print(plot_interval_structure_ev())
  })
  output$download_plot_interval_structure <- downloadHandler(
    filename = function() {
      fmt <- input$plot_format_interval_structure
      sprintf("plot_interval_structure.%s", fmt)
    },
    content = function(file) {
      p <- plot_interval_structure_ev()
      req(p)
      ggplot2::ggsave(
        filename = file,
        plot = p,
        width = input$plot_width_interval_structure,
        height = input$plot_height_interval_structure,
        dpi = input$plot_dpi_interval_structure,
        device = input$plot_format_interval_structure
      )
    }
  )

  plot_interval_flank_ev <- eventReactive(input$run_plot_interval_flank, {
    plot_interval_flank(
      gff_file = getGff(input$gff_file_flank),
      format = input$gff_format_flank,
      gene_id = input$flank_gene_id,
      flank_upstream = input$flank_upstream,
      flank_downstream = input$flank_downstream,
      show_promoters = input$show_promoters,
      upstream = input$upstream_flank,
      downstream = input$downstream_flank,
      arrow_length = input$arrow_length_flank,
      arrow_unit = input$arrow_unit_flank,
      gene_color = input$gene_color_flank,
      promoter_color = input$promoter_color_flank,
      label_size = input$label_size_flank
    )
  })
  output$plot_interval_flank <- renderPlot({
    req(plot_interval_flank_ev())
    print(plot_interval_flank_ev())
  })
  output$download_plot_interval_flank <- downloadHandler(
    filename = function() {
      fmt <- input$plot_format_interval_flank
      sprintf("plot_interval_flank.%s", fmt)
    },
    content = function(file) {
      p <- plot_interval_flank_ev()
      req(p)
      ggplot2::ggsave(
        filename = file,
        plot = p,
        width = input$plot_width_interval_flank,
        height = input$plot_height_interval_flank,
        dpi = input$plot_dpi_interval_flank,
        device = input$plot_format_interval_flank
      )
    }
  )

  plot_chrom_structure_ev <- eventReactive(input$run_plot_chrom_structure, {
    plot_chrom_structure(
      gff_file = getGff(input$gff_file_chrom),
      format = input$gff_format_chrom,
      orientation = input$chrom_orientation,
      bar_width = input$bar_width,
      chrom_alpha = input$chrom_alpha,
      gene_width = input$gene_width,
      chrom_color = input$chrom_color,
      gene_color = input$gene_color_chrom,
      telomere_color = input$telomere_color,
      label_size = input$label_size_chrom
    )
  })
  output$plot_chrom_structure <- renderPlot({
    req(plot_chrom_structure_ev())
    print(plot_chrom_structure_ev())
  })
  output$download_plot_chrom_structure <- downloadHandler(
    filename = function() {
      fmt <- input$plot_format_chrom_structure
      sprintf("plot_chrom_structure.%s", fmt)
    },
    content = function(file) {
      p <- plot_chrom_structure_ev()
      req(p)
      ggplot2::ggsave(
        filename = file,
        plot = p,
        width = input$plot_width_chrom_structure,
        height = input$plot_height_chrom_structure,
        dpi = input$plot_dpi_chrom_structure,
        device = input$plot_format_chrom_structure
      )
    }
  )

  plot_chrom_genes_ev <- eventReactive(input$run_plot_chrom_genes, {
    plot_chrom_genes(
      gff_file = getGff(input$gff_file_chrom_genes),
      gene_table = readGeneTable(input$gene_table_file),
      format = input$gff_format_chrom_genes,
      annotate = input$annotate_mode,
      orientation = input$chrom_genes_orientation,
      bar_width = input$bar_width_genes,
      chrom_alpha = input$chrom_alpha_genes,
      gene_width = input$gene_width_genes,
      chrom_color = input$chrom_color_genes,
      gene_color = input$gene_color_genes,
      telomere_color = input$telomere_color_genes,
      label_size = input$label_size_genes,
      connector_dx1 = input$connector_dx1_genes,
      connector_dx2 = input$connector_dx2_genes,
      min_gap_frac = input$min_gap_frac
    )
  })
  output$plot_chrom_genes <- renderPlot({
    req(plot_chrom_genes_ev())
    print(plot_chrom_genes_ev())
  })
  output$download_plot_chrom_genes <- downloadHandler(
    filename = function() {
      fmt <- input$plot_format_chrom_genes
      sprintf("plot_chrom_genes.%s", fmt)
    },
    content = function(file) {
      p <- plot_chrom_genes_ev()
      req(p)
      ggplot2::ggsave(
        filename = file,
        plot = p,
        width = input$plot_width_chrom_genes,
        height = input$plot_height_chrom_genes,
        dpi = input$plot_dpi_chrom_genes,
        device = input$plot_format_chrom_genes
      )
    }
  )

  plot_chrom_heatmap_ev <- eventReactive(input$run_plot_chrom_heatmap, {
    plot_chrom_heatmap(
      gff_file = getGff(input$gff_file_heatmap),
      format = input$gff_format_heatmap,
      feature = input$feature_type,
      bin_size = input$bin_size_heatmap,
      orientation = input$orientation_heatmap,
      palette = c(input$palette_start, input$palette_end),
      alpha = input$alpha_heatmap
    )
  })
  output$plot_chrom_heatmap <- renderPlot({
    req(plot_chrom_heatmap_ev())
    print(plot_chrom_heatmap_ev())
  })
  output$download_plot_chrom_heatmap <- downloadHandler(
    filename = function() {
      fmt <- input$plot_format_chrom_heatmap
      sprintf("plot_chrom_heatmap.%s", fmt)
    },
    content = function(file) {
      p <- plot_chrom_heatmap_ev()
      req(p)
      ggplot2::ggsave(
        filename = file,
        plot = p,
        width = input$plot_width_chrom_heatmap,
        height = input$plot_height_chrom_heatmap,
        dpi = input$plot_dpi_chrom_heatmap,
        device = input$plot_format_chrom_heatmap
      )
    }
  )

  plot_deg_chrom_ev <- eventReactive(input$run_plot_deg_chrom, {
    plot_deg_chrom(
      deg_file = getDeg(input$deg_file),
      gff_file = getGff(input$gff_file_deg),
      format = input$gff_format_deg,
      id_col = input$id_col,
      fc_col = input$fc_col,
      violin_scale = input$violin_scale,
      violin_border = input$violin_border,
      point_shape = input$point_shape_deg,
      point_size = input$point_size_deg,
      jitter_width = input$jitter_width_deg,
      hyper_color = input$hyper_color_deg,
      hypo_color = input$hypo_color_deg
    )
  })
  output$plot_deg_chrom <- renderPlot({
    req(plot_deg_chrom_ev())
    print(plot_deg_chrom_ev())
  })
  output$download_plot_deg_chrom <- downloadHandler(
    filename = function() {
      fmt <- input$plot_format_deg_chrom
      sprintf("plot_deg_chrom.%s", fmt)
    },
    content = function(file) {
      p <- plot_deg_chrom_ev()
      req(p)
      ggplot2::ggsave(
        filename = file,
        plot = p,
        width = input$plot_width_deg_chrom,
        height = input$plot_height_deg_chrom,
        dpi = input$plot_dpi_deg_chrom,
        device = input$plot_format_deg_chrom
      )
    }
  )

  plot_deg_exp_ev <- eventReactive(input$run_plot_deg_exp, {
    plot_deg_exp(
      deg_file = getDeg(input$deg_file_exp),
      gff_file = getGff(input$gff_file_deg_exp),
      format = input$gff_format_deg_exp,
      id_col = input$id_col_exp,
      fc_col = input$fc_col_exp,
      orientation = input$orientation_deg_exp,
      chrom_alpha = input$chrom_alpha_deg_exp,
      chrom_color = input$chrom_color_deg_exp,
      bar_height = input$bar_height_deg_exp,
      point_size = input$point_size_deg_exp,
      point_alpha = input$point_alpha_deg_exp,
      up_color = input$up_color_deg_exp,
      down_color = input$down_color_deg_exp,
      mark_style = input$mark_style_deg_exp,
      line_width = input$line_width_deg_exp,
      line_height = input$line_height_deg_exp
    )
  })
  output$plot_deg_exp <- renderPlot({
    req(plot_deg_exp_ev())
    print(plot_deg_exp_ev())
  })
  output$download_plot_deg_exp <- downloadHandler(
    filename = function() {
      fmt <- input$plot_format_deg_exp
      sprintf("plot_deg_exp.%s", fmt)
    },
    content = function(file) {
      p <- plot_deg_exp_ev()
      req(p)
      ggplot2::ggsave(
        filename = file,
        plot = p,
        width = input$plot_width_deg_exp,
        height = input$plot_height_deg_exp,
        dpi = input$plot_dpi_deg_exp,
        device = input$plot_format_deg_exp
      )
    }
  )

  plot_deg_volcano_ev <- eventReactive(input$run_plot_deg_volcano, {
    plot_deg_volcano(
      deg_file = getDeg(input$deg_file_volcano),
      id_col = input$id_col_volcano,
      fc_col = input$fc_col_volcano,
      sig_col = input$sig_col_volcano,
      fc_threshold = input$fc_threshold_volcano,
      sig_threshold = input$sig_threshold_volcano,
      point_size = input$point_size_volcano,
      point_alpha = input$point_alpha_volcano,
      up_color = input$up_color_volcano,
      down_color = input$down_color_volcano,
      ns_color = input$ns_color_volcano
    )
  })
  output$plot_deg_volcano <- renderPlot({
    req(plot_deg_volcano_ev())
    print(plot_deg_volcano_ev())
  })
  output$download_plot_deg_volcano <- downloadHandler(
    filename = function() {
      fmt <- input$plot_format_deg_volcano
      sprintf("plot_deg_volcano.%s", fmt)
    },
    content = function(file) {
      p <- plot_deg_volcano_ev()
      req(p)
      ggplot2::ggsave(
        filename = file,
        plot = p,
        width = input$plot_width_deg_volcano,
        height = input$plot_height_deg_volcano,
        dpi = input$plot_dpi_deg_volcano,
        device = input$plot_format_deg_volcano
      )
    }
  )

  plot_snp_fst_ev <- eventReactive(input$run_plot_snp_fst, {
    plot_snp_fst(
      fst_file = getFst(input$fst_file_heat),
      bin_size = input$bin_size_fst,
      metric = input$metric,
      orientation = input$orientation_fst,
      palette = c(input$palette_start_fst, input$palette_end_fst),
      alpha = input$alpha_fst
    )
  })
  output$plot_snp_fst <- renderPlot({
    req(plot_snp_fst_ev())
    print(plot_snp_fst_ev())
  })
  output$download_plot_snp_fst <- downloadHandler(
    filename = function() {
      fmt <- input$plot_format_snp_fst
      sprintf("plot_snp_fst.%s", fmt)
    },
    content = function(file) {
      p <- plot_snp_fst_ev()
      req(p)
      ggplot2::ggsave(
        filename = file,
        plot = p,
        width = input$plot_width_snp_fst,
        height = input$plot_height_snp_fst,
        dpi = input$plot_dpi_snp_fst,
        device = input$plot_format_snp_fst
      )
    }
  )

  plot_snp_anno_ev <- eventReactive(input$run_plot_snp_anno, {
    plot_snp_anno(
      fst_file = getFst(input$fst_file_anno),
      gff_file = getGff(input$gff_file_fst),
      format = input$gff_format_fst,
      chrom_id = input$chrom_id_fst,
      top_n = input$top_n,
      orientation = input$orientation_fst_anno,
      smooth_span = input$smooth_span,
      fst_color = input$fst_color,
      point_size = input$point_size_fst,
      point_alpha = input$point_alpha_fst,
      label_size = input$label_size_fst,
      connector_dx1 = input$connector_dx1,
      connector_dx2 = input$connector_dx2,
      gap_frac = input$gap_frac
    )
  })
  output$plot_snp_anno <- renderPlot({
    req(plot_snp_anno_ev())
    print(plot_snp_anno_ev())
  })
  output$download_plot_snp_anno <- downloadHandler(
    filename = function() {
      fmt <- input$plot_format_snp_anno
      sprintf("plot_snp_anno.%s", fmt)
    },
    content = function(file) {
      p <- plot_snp_anno_ev()
      req(p)
      ggplot2::ggsave(
        filename = file,
        plot = p,
        width = input$plot_width_snp_anno,
        height = input$plot_height_snp_anno,
        dpi = input$plot_dpi_snp_anno,
        device = input$plot_format_snp_anno
      )
    }
  )

  plot_dmg_chrom_ev <- eventReactive(input$run_plot_dmg_chrom, {
    plot_dmg_chrom(
      dmr_file = getDmr(input$dmr_file),
      violin_scale = input$violin_scale_dmr,
      violin_border = input$violin_border_dmr,
      point_shape = input$point_shape_dmr,
      point_size = input$point_size_dmr,
      jitter_width = input$jitter_width_dmr,
      hyper_color = input$hyper_color_dmr,
      hypo_color = input$hypo_color_dmr
    )
  })
  output$plot_dmg_chrom <- renderPlot({
    req(plot_dmg_chrom_ev())
    print(plot_dmg_chrom_ev())
  })
  output$download_plot_dmg_chrom <- downloadHandler(
    filename = function() {
      fmt <- input$plot_format_dmg_chrom
      sprintf("plot_dmg_chrom.%s", fmt)
    },
    content = function(file) {
      p <- plot_dmg_chrom_ev()
      req(p)
      ggplot2::ggsave(
        filename = file,
        plot = p,
        width = input$plot_width_dmg_chrom,
        height = input$plot_height_dmg_chrom,
        dpi = input$plot_dpi_dmg_chrom,
        device = input$plot_format_dmg_chrom
      )
    }
  )

  plot_dmg_trend_ev <- eventReactive(input$run_plot_dmg_trend, {
    plot_dmg_trend(
      chrom_id = input$chrom_id_trend,
      dmr_file = getDmr(input$dmr_file_trend),
      smooth_span = input$smooth_span_trend,
      hyper_color = input$hyper_color_trend,
      hypo_color = input$hypo_color_trend,
      point_size = input$point_size_trend,
      point_alpha = input$point_alpha_trend
    )
  })
  output$plot_dmg_trend <- renderPlot({
    req(plot_dmg_trend_ev())
    print(plot_dmg_trend_ev())
  })
  output$download_plot_dmg_trend <- downloadHandler(
    filename = function() {
      fmt <- input$plot_format_dmg_trend
      sprintf("plot_dmg_trend.%s", fmt)
    },
    content = function(file) {
      p <- plot_dmg_trend_ev()
      req(p)
      ggplot2::ggsave(
        filename = file,
        plot = p,
        width = input$plot_width_dmg_trend,
        height = input$plot_height_dmg_trend,
        dpi = input$plot_dpi_dmg_trend,
        device = input$plot_format_dmg_trend
      )
    }
  )

  plot_dmg_exp_ev <- eventReactive(input$run_plot_dmg_exp, {
    plot_dmg_exp(
      dmr_file = getDmr(input$dmr_file_exp),
      orientation = input$orientation_dmg_exp,
      chrom_alpha = input$chrom_alpha_dmg_exp,
      chrom_color = input$chrom_color_dmg_exp,
      bar_height = input$bar_height_dmg_exp,
      point_size = input$point_size_dmg_exp,
      point_alpha = input$point_alpha_dmg_exp,
      hyper_color = input$hyper_color_dmg_exp,
      hypo_color = input$hypo_color_dmg_exp,
      mark_style = input$mark_style_dmg_exp,
      line_width = input$line_width_dmg_exp,
      line_height = input$line_height_dmg_exp
    )
  })
  output$plot_dmg_exp <- renderPlot({
    req(plot_dmg_exp_ev())
    print(plot_dmg_exp_ev())
  })
  output$download_plot_dmg_exp <- downloadHandler(
    filename = function() {
      fmt <- input$plot_format_dmg_exp
      sprintf("plot_dmg_exp.%s", fmt)
    },
    content = function(file) {
      p <- plot_dmg_exp_ev()
      req(p)
      ggplot2::ggsave(
        filename = file,
        plot = p,
        width = input$plot_width_dmg_exp,
        height = input$plot_height_dmg_exp,
        dpi = input$plot_dpi_dmg_exp,
        device = input$plot_format_dmg_exp
      )
    }
  )

  plot_gene_stats_ev <- eventReactive(input$run_plot_gene_stats, {
    plot_gene_stats(
      gff_file = getGff(input$gff_file_gene_stats),
      format = input$gff_format_gene_stats,
      bar_width = input$bar_width_gene_stats,
      bar_color = input$bar_color_gene_stats,
      lable_size = input$label_size_gene_stats
    )
  })
  output$plot_gene_stats <- renderPlot({
    req(plot_gene_stats_ev())
    print(plot_gene_stats_ev())
  })
  output$download_plot_gene_stats <- downloadHandler(
    filename = function() {
      fmt <- input$plot_format_gene_stats
      sprintf("plot_gene_stats.%s", fmt)
    },
    content = function(file) {
      p <- plot_gene_stats_ev()
      req(p)
      ggplot2::ggsave(
        filename = file,
        plot = p,
        width = input$plot_width_gene_stats,
        height = input$plot_height_gene_stats,
        dpi = input$plot_dpi_gene_stats,
        device = input$plot_format_gene_stats
      )
    }
  )

  plot_snp_density_ev <- eventReactive(input$run_plot_snp_density, {
    plot_snp_density(
      fst_file = getFst(input$fst_file_density),
      LOG10 = input$log10_density,
      bin_size = input$bin_size_density,
      density_color = c(
        input$density_color1,
        input$density_color2,
        input$density_color3
      )
    )
  })
  output$plot_snp_density <- renderPlot({
    req(plot_snp_density_ev())
    print(plot_snp_density_ev())
  })
  output$download_plot_snp_density <- downloadHandler(
    filename = function() {
      fmt <- input$plot_format_snp_density
      sprintf("plot_snp_density.%s", fmt)
    },
    content = function(file) {
      p <- plot_snp_density_ev()
      req(p)
      ggplot2::ggsave(
        filename = file,
        plot = p,
        width = input$plot_width_snp_density,
        height = input$plot_height_snp_density,
        dpi = input$plot_dpi_snp_density,
        device = input$plot_format_snp_density
      )
    }
  )

  anno_fst_dmr_ev <- eventReactive(input$run_anno_fst_dmr, {
    anno_fst_dmr(
      gff_file = getGff(input$gff_file_anno_ranges),
      format = input$gff_format_anno_ranges,
      genomic_ranges = if (!is.null(input$genomic_ranges_file))
        input$genomic_ranges_file$datapath
      else
        getFst(NULL),
      chrom_col = input$chrom_col_ranges,
      start_col = input$start_col_ranges,
      end_col = input$end_col_ranges,
      upstream = input$upstream_ranges,
      downstream = input$downstream_ranges,
      ignore_strand = input$ignore_strand_ranges,
      features = input$features_ranges
    )
  })
  output$table_anno_fst_dmr <- DT::renderDataTable({
    req(anno_fst_dmr_ev())
    DT::datatable(
      anno_fst_dmr_ev(),
      options = list(pageLength = 10, scrollX = TRUE),
      rownames = FALSE
    )
  })
  output$download_table_anno_fst_dmr <- downloadHandler(
    filename = function() sprintf("anno_fst_dmr.txt"),
    content = function(file) {
      df <- anno_fst_dmr_ev()
      if (is.null(df)) df <- data.frame()
      utils::write.table(df, file, sep = "\t", row.names = FALSE, quote = FALSE)
    }
  )

  anno_deg_chrom_ev <- eventReactive(input$run_anno_deg_chrom, {
    anno_deg_chrom(
      deg_file = getDeg(input$deg_file_anno),
      gff_file = getGff(input$gff_file_deg_anno),
      format = input$gff_format_deg_anno,
      id_col = input$id_col_anno,
      fc_col = input$fc_col_anno,
      use_strand = input$use_strand_anno,
      drop_unmapped = input$drop_unmapped_anno
    )
  })
  output$table_anno_deg_chrom <- DT::renderDataTable({
    req(anno_deg_chrom_ev())
    DT::datatable(
      anno_deg_chrom_ev(),
      options = list(pageLength = 10, scrollX = TRUE),
      rownames = FALSE
    )
  })
  output$download_table_anno_deg_chrom <- downloadHandler(
    filename = function() sprintf("anno_deg_chrom.txt"),
    content = function(file) {
      df <- anno_deg_chrom_ev()
      if (is.null(df)) df <- data.frame()
      utils::write.table(df, file, sep = "\t", row.names = FALSE, quote = FALSE)
    }
  )

  plot_gene_domains_ev <- eventReactive(input$run_plot_gene_domains, {
    plot_gene_domains(
      gene_name = if (nzchar(input$transcript_id_domains)) NULL else input$gene_name_domains,
      species = input$species_domains,
      transcript_id = if (nzchar(input$transcript_id_domains)) input$transcript_id_domains else NULL,
      transcript_choice = input$transcript_choice_domains,
      palette = input$palette_domains,
      legend_ncol = input$legend_ncol_domains,
      return_data = FALSE
    )
  })
  output$plot_gene_domains <- renderPlot({
    req(plot_gene_domains_ev())
    print(plot_gene_domains_ev())
  })

  extract_promoters_ev <- eventReactive(input$run_extract_promoters, {
    extract_promoters(
      gff_file = getGff(input$gff_file_extract_promoters),
      format = input$gff_format_extract_promoters,
      upstream = input$upstream_extract_promoters,
      downstream = input$downstream_extract_promoters,
      promoter_info = input$promoter_info
    )
  })
  output$table_extract_promoters <- DT::renderDataTable({
    res <- extract_promoters_ev()
    if (is.null(res))
      return(DT::datatable(data.frame()))
    if (is(res, "GRanges")) {
      DT::datatable(
        grToDf(res),
        options = list(pageLength = 10, scrollX = TRUE),
        rownames = FALSE
      )
    } else if (is(res, "IRanges")) {
      DT::datatable(
        as.data.frame(res),
        options = list(pageLength = 10, scrollX = TRUE),
        rownames = FALSE
      )
    } else {
      DT::datatable(
        data.frame(value = res),
        options = list(pageLength = 10, scrollX = TRUE),
        rownames = FALSE
      )
    }
  })
  output$download_table_extract_promoters <- downloadHandler(
    filename = function() sprintf("extract_promoters.txt"),
    content = function(file) {
      res <- extract_promoters_ev()
      df <- if (is.null(res)) data.frame() else if (is(res, "GRanges")) grToDf(res) else if (is(res, "IRanges")) as.data.frame(res) else as.data.frame(res)
      utils::write.table(df, file, sep = "\t", row.names = FALSE, quote = FALSE)
    }
  )

  extract_utr5_ev <- eventReactive(input$run_extract_utr5, {
    extract_utr5(
      gff_file = getGff(input$gff_file_extract_utr5),
      format = input$gff_format_extract_utr5,
      utr5_info = input$utr5_info
    )
  })
  output$table_extract_utr5 <- DT::renderDataTable({
    res <- extract_utr5_ev()
    if (is.null(res))
      return(DT::datatable(data.frame()))
    if (is(res, "GRanges")) {
      DT::datatable(
        grToDf(res),
        options = list(pageLength = 10, scrollX = TRUE),
        rownames = FALSE
      )
    } else if (is(res, "IRanges")) {
      DT::datatable(
        as.data.frame(res),
        options = list(pageLength = 10, scrollX = TRUE),
        rownames = FALSE
      )
    } else {
      DT::datatable(
        data.frame(value = res),
        options = list(pageLength = 10, scrollX = TRUE),
        rownames = FALSE
      )
    }
  })
  output$download_table_extract_utr5 <- downloadHandler(
    filename = function() sprintf("extract_utr5.txt"),
    content = function(file) {
      res <- extract_utr5_ev()
      df <- if (is.null(res)) data.frame() else if (is(res, "GRanges")) grToDf(res) else if (is(res, "IRanges")) as.data.frame(res) else as.data.frame(res)
      utils::write.table(df, file, sep = "\t", row.names = FALSE, quote = FALSE)
    }
  )

  extract_genes_ev <- eventReactive(input$run_extract_genes, {
    extract_genes(
      gff_file = getGff(input$gff_file_extract_genes),
      format = input$gff_format_extract_genes,
      gene_info = input$gene_info_opt
    )
  })
  output$table_extract_genes <- DT::renderDataTable({
    res <- extract_genes_ev()
    if (is.null(res))
      return(DT::datatable(data.frame()))
    if (is(res, "GRanges")) {
      DT::datatable(
        grToDf(res),
        options = list(pageLength = 10, scrollX = TRUE),
        rownames = FALSE
      )
    } else if (is(res, "IRanges")) {
      DT::datatable(
        as.data.frame(res),
        options = list(pageLength = 10, scrollX = TRUE),
        rownames = FALSE
      )
    } else {
      DT::datatable(
        data.frame(value = res),
        options = list(pageLength = 10, scrollX = TRUE),
        rownames = FALSE
      )
    }
  })
  output$download_table_extract_genes <- downloadHandler(
    filename = function() sprintf("extract_genes.txt"),
    content = function(file) {
      res <- extract_genes_ev()
      df <- if (is.null(res)) data.frame() else if (is(res, "GRanges")) grToDf(res) else if (is(res, "IRanges")) as.data.frame(res) else as.data.frame(res)
      utils::write.table(df, file, sep = "\t", row.names = FALSE, quote = FALSE)
    }
  )

  extract_mrnas_ev <- eventReactive(input$run_extract_mrnas, {
    extract_mrnas(
      gff_file = getGff(input$gff_file_extract_mrnas),
      format = input$gff_format_extract_mrnas,
      mrna_info = input$mrna_info_opt
    )
  })
  output$table_extract_mrnas <- DT::renderDataTable({
    res <- extract_mrnas_ev()
    if (is.null(res))
      return(DT::datatable(data.frame()))
    if (is(res, "GRanges")) {
      DT::datatable(
        grToDf(res),
        options = list(pageLength = 10, scrollX = TRUE),
        rownames = FALSE
      )
    } else if (is(res, "IRanges")) {
      DT::datatable(
        as.data.frame(res),
        options = list(pageLength = 10, scrollX = TRUE),
        rownames = FALSE
      )
    } else {
      DT::datatable(
        data.frame(value = res),
        options = list(pageLength = 10, scrollX = TRUE),
        rownames = FALSE
      )
    }
  })
  output$download_table_extract_mrnas <- downloadHandler(
    filename = function() sprintf("extract_mrnas.txt"),
    content = function(file) {
      res <- extract_mrnas_ev()
      df <- if (is.null(res)) data.frame() else if (is(res, "GRanges")) grToDf(res) else if (is(res, "IRanges")) as.data.frame(res) else as.data.frame(res)
      utils::write.table(df, file, sep = "\t", row.names = FALSE, quote = FALSE)
    }
  )

  extract_cds_ev <- eventReactive(input$run_extract_cds, {
    extract_cds(
      gff_file = getGff(input$gff_file_extract_cds),
      format = input$gff_format_extract_cds,
      cds_info = input$cds_info_opt
    )
  })
  output$table_extract_cds <- DT::renderDataTable({
    res <- extract_cds_ev()
    if (is.null(res))
      return(DT::datatable(data.frame()))
    if (is(res, "GRanges")) {
      DT::datatable(
        grToDf(res),
        options = list(pageLength = 10, scrollX = TRUE),
        rownames = FALSE
      )
    } else if (is(res, "IRanges")) {
      DT::datatable(
        as.data.frame(res),
        options = list(pageLength = 10, scrollX = TRUE),
        rownames = FALSE
      )
    } else {
      DT::datatable(
        data.frame(value = res),
        options = list(pageLength = 10, scrollX = TRUE),
        rownames = FALSE
      )
    }
  })
  output$download_table_extract_cds <- downloadHandler(
    filename = function() sprintf("extract_cds.txt"),
    content = function(file) {
      res <- extract_cds_ev()
      df <- if (is.null(res)) data.frame() else if (is(res, "GRanges")) grToDf(res) else if (is(res, "IRanges")) as.data.frame(res) else as.data.frame(res)
      utils::write.table(df, file, sep = "\t", row.names = FALSE, quote = FALSE)
    }
  )

  extract_exons_ev <- eventReactive(input$run_extract_exons, {
    extract_exons(
      gff_file = getGff(input$gff_file_extract_exons),
      format = input$gff_format_extract_exons,
      exon_info = input$exon_info_opt
    )
  })
  output$table_extract_exons <- DT::renderDataTable({
    res <- extract_exons_ev()
    if (is.null(res))
      return(DT::datatable(data.frame()))
    if (is(res, "GRanges")) {
      DT::datatable(
        grToDf(res),
        options = list(pageLength = 10, scrollX = TRUE),
        rownames = FALSE
      )
    } else if (is(res, "IRanges")) {
      DT::datatable(
        as.data.frame(res),
        options = list(pageLength = 10, scrollX = TRUE),
        rownames = FALSE
      )
    } else {
      DT::datatable(
        data.frame(value = res),
        options = list(pageLength = 10, scrollX = TRUE),
        rownames = FALSE
      )
    }
  })
  output$download_table_extract_exons <- downloadHandler(
    filename = function() sprintf("extract_exons.txt"),
    content = function(file) {
      res <- extract_exons_ev()
      df <- if (is.null(res)) data.frame() else if (is(res, "GRanges")) grToDf(res) else if (is(res, "IRanges")) as.data.frame(res) else as.data.frame(res)
      utils::write.table(df, file, sep = "\t", row.names = FALSE, quote = FALSE)
    }
  )

  extract_utr3_ev <- eventReactive(input$run_extract_utr3, {
    extract_utr3(
      gff_file = getGff(input$gff_file_extract_utr3),
      format = input$gff_format_extract_utr3,
      utr3_info = input$utr3_info_opt
    )
  })
  output$table_extract_utr3 <- DT::renderDataTable({
    res <- extract_utr3_ev()
    if (is.null(res))
      return(DT::datatable(data.frame()))
    if (is(res, "GRanges")) {
      DT::datatable(
        grToDf(res),
        options = list(pageLength = 10, scrollX = TRUE),
        rownames = FALSE
      )
    } else if (is(res, "IRanges")) {
      DT::datatable(
        as.data.frame(res),
        options = list(pageLength = 10, scrollX = TRUE),
        rownames = FALSE
      )
    } else {
      DT::datatable(
        data.frame(value = res),
        options = list(pageLength = 10, scrollX = TRUE),
        rownames = FALSE
      )
    }
  })
  output$download_table_extract_utr3 <- downloadHandler(
    filename = function() sprintf("extract_utr3.txt"),
    content = function(file) {
      res <- extract_utr3_ev()
      df <- if (is.null(res)) data.frame() else if (is(res, "GRanges")) grToDf(res) else if (is(res, "IRanges")) as.data.frame(res) else as.data.frame(res)
      utils::write.table(df, file, sep = "\t", row.names = FALSE, quote = FALSE)
    }
  )
}

shinyApp(ui, server)

