library(shiny)
library(bs4Dash)
library(GAnnoViz)
library(ggplot2)
library(patchwork)
library(DT)
library(dplyr)

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
    bs4SidebarMenu(
      bs4SidebarMenuItem(
        text = "Extract Features",
        icon = icon("download"),
        startExpanded = FALSE,
        bs4SidebarMenuSubItem(text = "extract_promoters", tabName = "extract_promoters"),
        bs4SidebarMenuSubItem(text = "extract_utr5", tabName = "extract_utr5"),
        bs4SidebarMenuSubItem(text = "extract_genes", tabName = "extract_genes"),
        bs4SidebarMenuSubItem(text = "extract_mrnas", tabName = "extract_mrnas"),
        bs4SidebarMenuSubItem(text = "extract_cds", tabName = "extract_cds"),
        bs4SidebarMenuSubItem(text = "extract_exons", tabName = "extract_exons"),
        bs4SidebarMenuSubItem(text = "extract_utr3", tabName = "extract_utr3")
      ),
      bs4SidebarMenuItem(
        text = "Plot Structure",
        icon = icon("chart-line"),
        startExpanded = FALSE,
        bs4SidebarMenuSubItem(text = "plot_gene_stats", tabName = "plot_gene_stats"),
        bs4SidebarMenuSubItem(text = "plot_gene_structure", tabName = "plot_gene_structure"),
        bs4SidebarMenuSubItem(text = "plot_interval_structure", tabName = "plot_interval_structure"),
        bs4SidebarMenuSubItem(text = "plot_interval_flank", tabName = "plot_interval_flank"),
        bs4SidebarMenuSubItem(text = "plot_chrom_structure", tabName = "plot_chrom_structure"),
        bs4SidebarMenuSubItem(text = "plot_chrom_genes", tabName = "plot_chrom_genes"),
        bs4SidebarMenuSubItem(text = "plot_chrom_heatmap", tabName = "plot_chrom_heatmap")
      ),
      bs4SidebarMenuItem(
        text = "DEG Anno & Viz",
        icon = icon("chart-bar"),
        startExpanded = FALSE,
        bs4SidebarMenuSubItem(text = "anno_deg_chrom", tabName = "anno_deg_chrom"),
        bs4SidebarMenuSubItem(text = "plot_chrom_deg", tabName = "plot_chrom_deg")
      ),
      bs4SidebarMenuItem(
        text = "SNP Anno & Plot",
        icon = icon("dna"),
        startExpanded = FALSE,
        bs4SidebarMenuSubItem(text = "plot_snp_density", tabName = "plot_snp_density"),
        bs4SidebarMenuSubItem(text = "plot_snp_fst", tabName = "plot_snp_fst"),
        bs4SidebarMenuSubItem(text = "plot_snp_anno", tabName = "plot_snp_anno")
      ),
      bs4SidebarMenuItem(
        text = "DMG Anno & Plot",
        icon = icon("dot-circle"),
        startExpanded = FALSE,
        bs4SidebarMenuSubItem(text = "anno_fst_dmr", tabName = "anno_fst_dmr"),
        bs4SidebarMenuSubItem(text = "plot_dmg_chrom", tabName = "plot_dmg_chrom"),
        bs4SidebarMenuSubItem(text = "plot_dmg_trend", tabName = "plot_dmg_trend")
      )
    )
  ),
  body = bs4DashBody(
    tags$head(tags$link(rel = "stylesheet", href = "style.css")),
    bs4TabItems(
      bs4TabItem(tabName = "plot_gene_structure", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = "Parameters",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            fileInput("gff_file_gene", "GFF/GTF file"),
            selectInput("gff_format_gene", "Format", choices = c("auto","gff3","gtf"), selected = "auto"),
            textInput("gene_id", "Gene ID", value = "HdF029609"),
            numericInput("upstream", "Promoter upstream", value = 2000, min = 0, step = 100),
            numericInput("downstream", "Promoter downstream", value = 200, min = 0, step = 50),
            sliderInput("feature_alpha", "Feature alpha", min = 0, max = 1, value = 0.8, step = 0.05),
            numericInput("intron_width", "Intron width", value = 1, min = 0, step = 0.5),
            numericInput("x_breaks", "X breaks", value = 10, min = 2, step = 1),
            numericInput("arrow_length", "Arrow length", value = 5, min = 1, step = 1),
            numericInput("arrow_count", "Arrow count", value = 1, min = 0, step = 1),
            selectInput("arrow_unit", "Arrow unit", choices = c("pt","mm","cm","inches"), selected = "pt"),
            textInput("promoter_color", "Promoter color", value = "#ff8800"),
            textInput("utr5_color", "5'UTR color", value = "#008833"),
            textInput("utr3_color", "3'UTR color", value = "#ff0033"),
            textInput("exon_color", "Exon color", value = "#0033ff"),
            textInput("intron_color", "Intron color", value = "#333333"),
            actionButton("run_plot_gene_structure", "Run")
          )
        ),
        column(
          width = 9,
          bs4Card(
            title = "Plot",
            status = "danger",
            solidHeader = TRUE,
            width = 12,
            plotOutput("plot_gene_structure", height = "600px")
          ),

        )
      )),

      bs4TabItem(tabName = "plot_dmg_trend", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = "Parameters",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            fileInput("dmr_file_trend", "DMR table"),
            textInput("chrom_id_trend", "Chrom ID", value = "chr1"),
            sliderInput("smooth_span_trend", "Smooth span", min = 0.05, max = 1, value = 0.1, step = 0.05),
            textInput("hyper_color_trend", "Hyper color", value = "#ff000055"),
            textInput("hypo_color_trend", "Hypo color", value = "#00880055"),
            numericInput("point_size_trend", "Point size", value = 3, min = 0.5, step = 0.5),
            sliderInput("point_alpha_trend", "Point alpha", min = 0, max = 1, value = 0.5, step = 0.05),
            actionButton("run_plot_dmg_trend", "Run")
          )
        ),
        column(
          width = 9,
          bs4Card(
            title = "Plot",
            status = "danger",
            solidHeader = TRUE,
            width = 12,
            plotOutput("plot_dmg_trend", height = "600px")
          ),

        )
      )),

      bs4TabItem(tabName = "plot_interval_structure", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = "Parameters",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            fileInput("gff_file_interval", "GFF/GTF file"),
            selectInput("gff_format_interval", "Format", choices = c("auto","gff3","gtf"), selected = "auto"),
            textInput("chrom_id", "Chrom ID", value = "chr1"),
            numericInput("win_start", "Start", value = 950000, min = 0, step = 1000),
            numericInput("win_end", "End", value = 1180000, min = 0, step = 1000),
            numericInput("x_breaks_interval", "X breaks", value = 10, min = 2, step = 1),
            numericInput("upstream_interval", "Promoter upstream", value = 2000, min = 0, step = 100),
            numericInput("downstream_interval", "Promoter downstream", value = 200, min = 0, step = 50),
            sliderInput("feature_alpha_interval", "Feature alpha", min = 0, max = 1, value = 0.8, step = 0.05),
            numericInput("intron_width_interval", "Intron width", value = 1, min = 0, step = 0.5),
            numericInput("arrow_length_interval", "Arrow length", value = 5, min = 1, step = 1),
            numericInput("arrow_count_interval", "Arrow count", value = 1, min = 0, step = 1),
            selectInput("arrow_unit_interval", "Arrow unit", choices = c("pt","mm","cm","inches"), selected = "pt"),
            textInput("promoter_color_interval", "Promoter color", value = "#ff8800"),
            textInput("utr5_color_interval", "5'UTR color", value = "#008833"),
            textInput("utr3_color_interval", "3'UTR color", value = "#ff0033"),
            textInput("exon_color_interval", "Exon color", value = "#0033ff"),
            textInput("intron_color_interval", "Intron color", value = "#333333"),
            actionButton("run_plot_interval_structure", "Run")
          )
        ),
        column(
          width = 9,
          bs4Card(
            title = "Plot",
            status = "danger",
            solidHeader = TRUE,
            width = 12,
            plotOutput("plot_interval_structure", height = "600px")
          ),

        )
      )),

      bs4TabItem(tabName = "plot_interval_flank", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = "Parameters",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            fileInput("gff_file_flank", "GFF/GTF file"),
            selectInput("gff_format_flank", "Format", choices = c("auto","gff3","gtf"), selected = "auto"),
            textInput("flank_gene_id", "Gene ID", value = "HdF029609"),
            numericInput("flank_upstream", "Flank upstream", value = 200000, min = 0, step = 1000),
            numericInput("flank_downstream", "Flank downstream", value = 200000, min = 0, step = 1000),
            checkboxInput("show_promoters", "Show promoters", value = TRUE),
            numericInput("upstream_flank", "Promoter upstream", value = 2000, min = 0, step = 100),
            numericInput("downstream_flank", "Promoter downstream", value = 200, min = 0, step = 50),
            numericInput("arrow_length_flank", "Arrow length", value = 5, min = 1, step = 1),
            selectInput("arrow_unit_flank", "Arrow unit", choices = c("pt","mm","cm","inches"), selected = "pt"),
            textInput("gene_color_flank", "Gene color", value = "#0088ff"),
            textInput("promoter_color_flank", "Promoter color", value = "#ff8800"),
            numericInput("label_size_flank", "Label size", value = 3, min = 1, step = 1),
            actionButton("run_plot_interval_flank", "Run")
          )
        ),
        column(
          width = 9,
          bs4Card(
            title = "Plot",
            status = "danger",
            solidHeader = TRUE,
            width = 12,
            plotOutput("plot_interval_flank", height = "600px")
          ),

        )
      )),

      bs4TabItem(tabName = "plot_chrom_structure", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = "Parameters",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            fileInput("gff_file_chrom", "GFF/GTF file"),
            selectInput("gff_format_chrom", "Format", choices = c("auto","gff3","gtf"), selected = "auto"),
            selectInput("chrom_orientation", "Orientation", choices = c("vertical","horizontal"), selected = "vertical"),
            sliderInput("bar_width", "Bar width", min = 0.1, max = 1, value = 0.6, step = 0.05),
            sliderInput("chrom_alpha", "Chrom alpha", min = 0, max = 1, value = 0.1, step = 0.05),
            sliderInput("gene_width", "Gene width", min = 0.1, max = 1, value = 0.5, step = 0.05),
            textInput("chrom_color", "Chrom color", value = "#008888"),
            textInput("gene_color_chrom", "Gene color", value = "#0088ff"),
            textInput("telomere_color", "Telomere color", value = "#ff0000"),
            numericInput("label_size_chrom", "Label size", value = 3, min = 1, step = 1),
            actionButton("run_plot_chrom_structure", "Run")
          )
        ),
        column(
          width = 9,
          bs4Card(
            title = "Plot",
            status = "danger",
            solidHeader = TRUE,
            width = 12,
            plotOutput("plot_chrom_structure", height = "600px")
          ),

        )
      )),

      bs4TabItem(tabName = "plot_chrom_genes", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = "Parameters",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            fileInput("gff_file_chrom_genes", "GFF/GTF file"),
            selectInput("gff_format_chrom_genes", "Format", choices = c("auto","gff3","gtf"), selected = "auto"),
            fileInput("gene_table_file", "Gene table (2 cols: id,name)"),
            selectInput("annotate_mode", "Annotate", choices = c("id","name"), selected = "id"),
            selectInput("chrom_genes_orientation", "Orientation", choices = c("vertical","horizontal"), selected = "vertical"),
            sliderInput("min_gap_frac", "Min gap frac", min = 0.005, max = 0.1, value = 0.02, step = 0.005),
            sliderInput("bar_width_genes", "Bar width", min = 0.1, max = 1, value = 0.6, step = 0.05),
            sliderInput("chrom_alpha_genes", "Chrom alpha", min = 0, max = 1, value = 0.1, step = 0.05),
            sliderInput("gene_width_genes", "Gene width", min = 0.1, max = 1, value = 0.5, step = 0.05),
            textInput("chrom_color_genes", "Chrom color", value = "#008888"),
            textInput("gene_color_genes", "Gene color", value = "#0088ff"),
            textInput("telomere_color_genes", "Telomere color", value = "#ff0000"),
            numericInput("label_size_genes", "Label size", value = 3, min = 1, step = 1),
            numericInput("connector_dx1_genes", "Connector dx1", value = 0.2, min = 0, step = 0.05),
            numericInput("connector_dx2_genes", "Connector dx2", value = 0.2, min = 0, step = 0.05),
            actionButton("run_plot_chrom_genes", "Run")
          )
        ),
        column(
          width = 9,
          bs4Card(
            title = "Plot",
            status = "danger",
            solidHeader = TRUE,
            width = 12,
            plotOutput("plot_chrom_genes", height = "600px")
          ),

        )
      )),

      bs4TabItem(tabName = "plot_chrom_heatmap", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = "Parameters",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            fileInput("gff_file_heatmap", "GFF/GTF file"),
            selectInput("gff_format_heatmap", "Format", choices = c("auto","gff3","gtf"), selected = "auto"),
            selectInput("feature_type", "Feature", choices = c("gene","exon","CDS","promoter"), selected = "gene"),
            numericInput("bin_size_heatmap", "Bin size", value = 1e6, min = 1e4, step = 1e5),
            selectInput("orientation_heatmap", "Orientation", choices = c("horizontal","vertical"), selected = "horizontal"),
            textInput("palette_start", "Palette start", value = "#ffffff"),
            textInput("palette_end", "Palette end", value = "#0055aa"),
            sliderInput("alpha_heatmap", "Alpha", min = 0, max = 1, value = 0.9, step = 0.05),
            actionButton("run_plot_chrom_heatmap", "Run")
          )
        ),
        column(
          width = 9,
          bs4Card(
            title = "Plot",
            status = "danger",
            solidHeader = TRUE,
            width = 12,
            plotOutput("plot_chrom_heatmap", height = "600px")
          ),

        )
      )),

      bs4TabItem(tabName = "plot_chrom_deg", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = "Parameters",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            fileInput("deg_file", "DEG table"),
            fileInput("gff_file_deg", "GFF/GTF file"),
            selectInput("gff_format_deg", "Format", choices = c("auto","gff3","gtf"), selected = "auto"),
            textInput("id_col", "ID column", value = "GeneID"),
            textInput("fc_col", "FC column", value = "log2FoldChange"),
            selectInput("violin_scale", "Violin scale", choices = c("count","area","width"), selected = "count"),
            sliderInput("violin_border", "Violin border", min = 0, max = 2, value = 0.5, step = 0.1),
            numericInput("point_shape_deg", "Point shape", value = 16, min = 0, step = 1),
            numericInput("point_size_deg", "Point size", value = 2, min = 0.5, step = 0.5),
            sliderInput("jitter_width_deg", "Jitter width", min = 0, max = 1, value = 0.2, step = 0.05),
            textInput("hyper_color_deg", "Hyper color", value = "#ff000088"),
            textInput("hypo_color_deg", "Hypo color", value = "#00880088"),
            actionButton("run_plot_chrom_deg", "Run")
          )
        ),
        column(
          width = 9,
          bs4Card(
            title = "Plot",
            status = "danger",
            solidHeader = TRUE,
            width = 12,
            plotOutput("plot_chrom_deg", height = "600px")
          ),

        )
      )),

      bs4TabItem(tabName = "plot_snp_fst", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = "Parameters",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            fileInput("fst_file_heat", "FST table"),
            numericInput("bin_size_fst", "Bin size", value = 1e6, min = 1e4, step = 1e5),
            selectInput("metric", "Metric", choices = c("fst_mean","variant_count"), selected = "fst_mean"),
            selectInput("orientation_fst", "Orientation", choices = c("horizontal","vertical"), selected = "horizontal"),
            textInput("palette_start_fst", "Palette start", value = "#ffffff"),
            textInput("palette_end_fst", "Palette end", value = "#aa00aa"),
            sliderInput("alpha_fst", "Alpha", min = 0, max = 1, value = 0.9, step = 0.05),
            actionButton("run_plot_snp_fst", "Run")
          )
        ),
        column(
          width = 9,
          bs4Card(
            title = "Plot",
            status = "danger",
            solidHeader = TRUE,
            width = 12,
            plotOutput("plot_snp_fst", height = "600px")
          ),

        )
      )),

      bs4TabItem(tabName = "plot_snp_anno", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = "Parameters",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            fileInput("fst_file_anno", "FST table"),
            fileInput("gff_file_fst", "GFF/GTF file"),
            selectInput("gff_format_fst", "Format", choices = c("auto","gff3","gtf"), selected = "auto"),
            textInput("chrom_id_fst", "Chrom ID", value = "chr2"),
            numericInput("top_n", "Top N", value = 20, min = 1, step = 1),
            selectInput("orientation_fst_anno", "Orientation", choices = c("vertical","horizontal"), selected = "vertical"),
            sliderInput("smooth_span", "Smooth span", min = 0.05, max = 1, value = 0.5, step = 0.05),
            numericInput("point_size_fst", "Point size", value = 1, min = 0.5, step = 0.5),
            sliderInput("point_alpha_fst", "Point alpha", min = 0, max = 1, value = 0.3, step = 0.05),
            numericInput("label_size_fst", "Label size", value = 3, min = 1, step = 1),
            numericInput("connector_dx1", "Connector dx1", value = 2e4, min = 0, step = 1e3),
            numericInput("connector_dx2", "Connector dx2", value = 4e4, min = 0, step = 1e3),
            sliderInput("gap_frac", "Gap frac", min = 0.01, max = 0.2, value = 0.05, step = 0.01),
            textInput("fst_color", "FST color", value = "#0088ff"),
            actionButton("run_plot_snp_anno", "Run")
          )
        ),
        column(
          width = 9,
          bs4Card(
            title = "Plot",
            status = "danger",
            solidHeader = TRUE,
            width = 12,
            plotOutput("plot_snp_anno", height = "600px")
          ),

        )
      )),

      bs4TabItem(tabName = "plot_dmg_chrom", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = "Parameters",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            fileInput("dmr_file", "DMR table"),
            selectInput("violin_scale_dmr", "Violin scale", choices = c("count","area","width"), selected = "count"),
            sliderInput("violin_border_dmr", "Violin border", min = 0, max = 2, value = 0.5, step = 0.1),
            numericInput("point_shape_dmr", "Point shape", value = 8, min = 0, step = 1),
            numericInput("point_size_dmr", "Point size", value = 2, min = 0.5, step = 0.5),
            sliderInput("jitter_width_dmr", "Jitter width", min = 0, max = 1, value = 0.2, step = 0.05),
            textInput("hyper_color_dmr", "Hyper color", value = "#ff880088"),
            textInput("hypo_color_dmr", "Hypo color", value = "#0088ff88"),
            actionButton("run_plot_dmg_chrom", "Run")
          )
        ),
        column(
          width = 9,
          bs4Card(
            title = "Plot",
            status = "danger",
            solidHeader = TRUE,
            width = 12,
            plotOutput("plot_dmg_chrom", height = "600px")
          ),

        )
      ))
      ,
      bs4TabItem(tabName = "plot_gene_stats", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = "Parameters",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            fileInput("gff_file_gene_stats", "GFF/GTF file"),
            selectInput("gff_format_gene_stats", "Format", choices = c("auto","gff3","gtf"), selected = "auto"),
            sliderInput("bar_width_gene_stats", "Bar width", min = 0.1, max = 1, value = 0.7, step = 0.05),
            textInput("bar_color_gene_stats", "Bar color", value = "#0055ff55"),
            numericInput("label_size_gene_stats", "Label size", value = 3, min = 1, step = 1),
            actionButton("run_plot_gene_stats", "Run")
          )
        ),
        column(
          width = 9,
          bs4Card(
            title = "Plot",
            status = "danger",
            solidHeader = TRUE,
            width = 12,
            plotOutput("plot_gene_stats", height = "600px")
          )
        )
      )),
      bs4TabItem(tabName = "plot_snp_density", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = "Parameters",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            fileInput("fst_file_density", "FST table"),
            checkboxInput("log10_density", "LOG10", value = FALSE),
            numericInput("bin_size_density", "Bin size", value = 1e6, min = 1e4, step = 1e5),
            textInput("density_color1", "Density color 1", value = "#0088ff"),
            textInput("density_color2", "Density color 2", value = "#ff8800"),
            textInput("density_color3", "Density color 3", value = "#ff0000"),
            actionButton("run_plot_snp_density", "Run")
          )
        ),
        column(
          width = 9,
          bs4Card(
            title = "Plot",
            status = "danger",
            solidHeader = TRUE,
            width = 12,
            plotOutput("plot_snp_density", height = "600px")
          )
        )
      )),
      bs4TabItem(tabName = "anno_fst_dmr", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = "Parameters",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            fileInput("gff_file_anno_ranges", "GFF/GTF file"),
            selectInput("gff_format_anno_ranges", "Format", choices = c("auto","gff3","gtf"), selected = "auto"),
            fileInput("genomic_ranges_file", "Genomic ranges (FST/DMR)"),
            textInput("chrom_col_ranges", "Chrom column", value = "CHROM"),
            textInput("start_col_ranges", "Start column", value = "BIN_START"),
            textInput("end_col_ranges", "End column", value = "BIN_END"),
            numericInput("upstream_ranges", "Promoter upstream", value = 2000, min = 0, step = 100),
            numericInput("downstream_ranges", "Promoter downstream", value = 200, min = 0, step = 50),
            checkboxInput("ignore_strand_ranges", "Ignore strand", value = TRUE),
            selectInput("features_ranges", "Features", multiple = TRUE,
                        choices = c("promoter","UTR5","gene","exon","intron","CDS","UTR3","intergenic"),
                        selected = c("promoter","UTR5","gene","exon","intron","CDS","UTR3")),
            actionButton("run_anno_fst_dmr", "Run")
          )
        ),
        column(
          width = 9,
          bs4Card(
            title = "Data",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("table_anno_fst_dmr")
          )
        )
      )),
      bs4TabItem(tabName = "extract_promoters", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = "Parameters",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            fileInput("gff_file_extract_promoters", "GFF/GTF file"),
            selectInput("gff_format_extract_promoters", "Format", choices = c("auto","gff3","gtf"), selected = "auto"),
            numericInput("upstream_extract_promoters", "Promoter upstream", value = 2000, min = 0, step = 100),
            numericInput("downstream_extract_promoters", "Promoter downstream", value = 200, min = 0, step = 50),
            selectInput("promoter_info", "Info", choices = c("all","chrom_id","promoter_id","promoter_range"), selected = "all"),
            actionButton("run_extract_promoters", "Run")
          )
        ),
        column(
          width = 9,
          bs4Card(
            title = "Data",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("table_extract_promoters")
          )
        )
      )),
      bs4TabItem(tabName = "extract_utr5", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = "Parameters",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            fileInput("gff_file_extract_utr5", "GFF/GTF file"),
            selectInput("gff_format_extract_utr5", "Format", choices = c("auto","gff3","gtf"), selected = "auto"),
            selectInput("utr5_info", "Info", choices = c("all","chrom_id","utr5_range"), selected = "all"),
            actionButton("run_extract_utr5", "Run")
          )
        ),
        column(
          width = 9,
          bs4Card(
            title = "Data",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("table_extract_utr5")
          )
        )
      )),
      bs4TabItem(tabName = "extract_genes", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = "Parameters",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            fileInput("gff_file_extract_genes", "GFF/GTF file"),
            selectInput("gff_format_extract_genes", "Format", choices = c("auto","gff3","gtf"), selected = "auto"),
            selectInput("gene_info_opt", "Info", choices = c("all","chrom_id","gene_id","gene_range"), selected = "all"),
            actionButton("run_extract_genes", "Run")
          )
        ),
        column(
          width = 9,
          bs4Card(
            title = "Data",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("table_extract_genes")
          )
        )
      )),
      bs4TabItem(tabName = "extract_mrnas", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = "Parameters",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            fileInput("gff_file_extract_mrnas", "GFF/GTF file"),
            selectInput("gff_format_extract_mrnas", "Format", choices = c("auto","gff3","gtf"), selected = "auto"),
            selectInput("mrna_info_opt", "Info", choices = c("all","chrom_id","mrna_id","mrna_range"), selected = "all"),
            actionButton("run_extract_mrnas", "Run")
          )
        ),
        column(
          width = 9,
          bs4Card(
            title = "Data",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("table_extract_mrnas")
          )
        )
      )),
      bs4TabItem(tabName = "extract_cds", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = "Parameters",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            fileInput("gff_file_extract_cds", "GFF/GTF file"),
            selectInput("gff_format_extract_cds", "Format", choices = c("auto","gff3","gtf"), selected = "auto"),
            selectInput("cds_info_opt", "Info", choices = c("all","chrom_id","cds_id","cds_range"), selected = "all"),
            actionButton("run_extract_cds", "Run")
          )
        ),
        column(
          width = 9,
          bs4Card(
            title = "Data",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("table_extract_cds")
          )
        )
      )),
      bs4TabItem(tabName = "extract_exons", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = "Parameters",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            fileInput("gff_file_extract_exons", "GFF/GTF file"),
            selectInput("gff_format_extract_exons", "Format", choices = c("auto","gff3","gtf"), selected = "auto"),
            selectInput("exon_info_opt", "Info", choices = c("all","chrom_id","exon_id","exon_range"), selected = "all"),
            actionButton("run_extract_exons", "Run")
          )
        ),
        column(
          width = 9,
          bs4Card(
            title = "Data",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("table_extract_exons")
          )
        )
      )),
      bs4TabItem(tabName = "extract_utr3", fluidRow(
        column(
          width = 3,
          bs4Card(
            title = "Parameters",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            fileInput("gff_file_extract_utr3", "GFF/GTF file"),
            selectInput("gff_format_extract_utr3", "Format", choices = c("auto","gff3","gtf"), selected = "auto"),
            selectInput("utr3_info_opt", "Info", choices = c("all","chrom_id","utr3_range"), selected = "all"),
            actionButton("run_extract_utr3", "Run")
          )
        ),
        column(
          width = 9,
          bs4Card(
            title = "Data",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("table_extract_utr3")
          )
        )
      ))
    )
  )
)

server <- function(input, output, session) {
  getGff <- function(infile) {
    if (!is.null(infile)) infile$datapath else system.file("extdata","example.gff", package = "GAnnoViz")
  }
  getDeg <- function(infile) {
    if (!is.null(infile)) infile$datapath else system.file("extdata","example.deg", package = "GAnnoViz")
  }
  getFst <- function(infile) {
    if (!is.null(infile)) infile$datapath else system.file("extdata","example.fst", package = "GAnnoViz")
  }
  getDmr <- function(infile) {
    if (!is.null(infile)) infile$datapath else system.file("extdata","example.dmr", package = "GAnnoViz")
  }
  readGeneTable <- function(infile) {
    if (is.null(infile)) {
      data.frame(gene_id = c("HdF029609","HdF029610"), gene_name = c("GeneA","GeneB"), stringsAsFactors = FALSE)
    } else {
      utils::read.table(infile$datapath, header = TRUE, sep = "\t", stringsAsFactors = FALSE, check.names = FALSE)
    }
  }
  grToDf <- function(gr) {
    if (is.null(gr)) return(data.frame())
    data.frame(
      chrom = as.character(GenomicRanges::seqnames(gr)),
      start = BiocGenerics::start(gr),
      end = BiocGenerics::end(gr),
      as.data.frame(S4Vectors::mcols(gr)),
      stringsAsFactors = FALSE
    )
  }

  dfGeneFeatures <- function(gff_file, format, gene_id, upstream, downstream) {
    txdb <- suppressWarnings(txdbmaker::makeTxDbFromGFF(file = gff_file, format = format))
    genes <- suppressWarnings(GenomicFeatures::genes(txdb))
    if (!(gene_id %in% genes$gene_id)) return(data.frame())
    exons_by_tx <- suppressWarnings(GenomicFeatures::exonsBy(txdb, by = "tx"))
    introns_by_tx <- suppressWarnings(GenomicFeatures::intronsByTranscript(txdb, use.names = TRUE))
    utr5_by_tx <- suppressWarnings(GenomicFeatures::fiveUTRsByTranscript(txdb, use.names = TRUE))
    utr3_by_tx <- suppressWarnings(GenomicFeatures::threeUTRsByTranscript(txdb, use.names = TRUE))
    promoters_tx <- suppressWarnings(GenomicFeatures::promoters(txdb, upstream = upstream, downstream = downstream, use.names = TRUE))
    tx_by_gene <- suppressWarnings(GenomicFeatures::transcriptsBy(txdb, by = "gene"))
    tx_names <- if (gene_id %in% names(tx_by_gene)) tx_by_gene[[gene_id]]$tx_name else character(0)
    build_df <- function(gr_list, feature) {
      if (is.null(gr_list) || length(gr_list) == 0) return(data.frame())
      lst <- split(gr_list, gr_list$tx_name)
      lst <- lst[names(lst) %in% tx_names]
      if (length(lst) == 0) return(data.frame())
      dfs <- lapply(names(lst), function(nm) {
        gr <- lst[[nm]]
        data.frame(tx_name = nm,
                   feature = feature,
                   start = BiocGenerics::start(gr),
                   end = BiocGenerics::end(gr),
                   strand = as.character(GenomicRanges::strand(gr)),
                   stringsAsFactors = FALSE)
      })
      do.call(rbind, dfs)
    }
    df <- do.call(rbind, list(
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

  plot_chrom_deg_ev <- eventReactive(input$run_plot_chrom_deg, {
    plot_chrom_deg(
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
  output$plot_chrom_deg <- renderPlot({
    req(plot_chrom_deg_ev())
    print(plot_chrom_deg_ev())
  })

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

  plot_snp_density_ev <- eventReactive(input$run_plot_snp_density, {
    plot_snp_density(
      fst_file = getFst(input$fst_file_density),
      LOG10 = input$log10_density,
      bin_size = input$bin_size_density,
      density_color = c(input$density_color1, input$density_color2, input$density_color3)
    )
  })
  output$plot_snp_density <- renderPlot({
    req(plot_snp_density_ev())
    print(plot_snp_density_ev())
  })

  anno_fst_dmr_ev <- eventReactive(input$run_anno_fst_dmr, {
    anno_fst_dmr(
      gff_file = getGff(input$gff_file_anno_ranges),
      format = input$gff_format_anno_ranges,
      genomic_ranges = if (!is.null(input$genomic_ranges_file)) input$genomic_ranges_file$datapath else getFst(NULL),
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
    DT::datatable(anno_fst_dmr_ev(), options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
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
    if (is.null(res)) return(DT::datatable(data.frame()))
    if (is(res, "GRanges")) {
      DT::datatable(grToDf(res), options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
    } else if (is(res, "IRanges")) {
      DT::datatable(as.data.frame(res), options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
    } else {
      DT::datatable(data.frame(value = res), options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
    }
  })

  extract_utr5_ev <- eventReactive(input$run_extract_utr5, {
    extract_utr5(
      gff_file = getGff(input$gff_file_extract_utr5),
      format = input$gff_format_extract_utr5,
      utr5_info = input$utr5_info
    )
  })
  output$table_extract_utr5 <- DT::renderDataTable({
    res <- extract_utr5_ev()
    if (is.null(res)) return(DT::datatable(data.frame()))
    if (is(res, "GRanges")) {
      DT::datatable(grToDf(res), options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
    } else if (is(res, "IRanges")) {
      DT::datatable(as.data.frame(res), options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
    } else {
      DT::datatable(data.frame(value = res), options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
    }
  })

  extract_genes_ev <- eventReactive(input$run_extract_genes, {
    extract_genes(
      gff_file = getGff(input$gff_file_extract_genes),
      format = input$gff_format_extract_genes,
      gene_info = input$gene_info_opt
    )
  })
  output$table_extract_genes <- DT::renderDataTable({
    res <- extract_genes_ev()
    if (is.null(res)) return(DT::datatable(data.frame()))
    if (is(res, "GRanges")) {
      DT::datatable(grToDf(res), options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
    } else if (is(res, "IRanges")) {
      DT::datatable(as.data.frame(res), options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
    } else {
      DT::datatable(data.frame(value = res), options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
    }
  })

  extract_mrnas_ev <- eventReactive(input$run_extract_mrnas, {
    extract_mrnas(
      gff_file = getGff(input$gff_file_extract_mrnas),
      format = input$gff_format_extract_mrnas,
      mrna_info = input$mrna_info_opt
    )
  })
  output$table_extract_mrnas <- DT::renderDataTable({
    res <- extract_mrnas_ev()
    if (is.null(res)) return(DT::datatable(data.frame()))
    if (is(res, "GRanges")) {
      DT::datatable(grToDf(res), options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
    } else if (is(res, "IRanges")) {
      DT::datatable(as.data.frame(res), options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
    } else {
      DT::datatable(data.frame(value = res), options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
    }
  })

  extract_cds_ev <- eventReactive(input$run_extract_cds, {
    extract_cds(
      gff_file = getGff(input$gff_file_extract_cds),
      format = input$gff_format_extract_cds,
      cds_info = input$cds_info_opt
    )
  })
  output$table_extract_cds <- DT::renderDataTable({
    res <- extract_cds_ev()
    if (is.null(res)) return(DT::datatable(data.frame()))
    if (is(res, "GRanges")) {
      DT::datatable(grToDf(res), options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
    } else if (is(res, "IRanges")) {
      DT::datatable(as.data.frame(res), options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
    } else {
      DT::datatable(data.frame(value = res), options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
    }
  })

  extract_exons_ev <- eventReactive(input$run_extract_exons, {
    extract_exons(
      gff_file = getGff(input$gff_file_extract_exons),
      format = input$gff_format_extract_exons,
      exon_info = input$exon_info_opt
    )
  })
  output$table_extract_exons <- DT::renderDataTable({
    res <- extract_exons_ev()
    if (is.null(res)) return(DT::datatable(data.frame()))
    if (is(res, "GRanges")) {
      DT::datatable(grToDf(res), options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
    } else if (is(res, "IRanges")) {
      DT::datatable(as.data.frame(res), options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
    } else {
      DT::datatable(data.frame(value = res), options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
    }
  })

  extract_utr3_ev <- eventReactive(input$run_extract_utr3, {
    extract_utr3(
      gff_file = getGff(input$gff_file_extract_utr3),
      format = input$gff_format_extract_utr3,
      utr3_info = input$utr3_info_opt
    )
  })
  output$table_extract_utr3 <- DT::renderDataTable({
    res <- extract_utr3_ev()
    if (is.null(res)) return(DT::datatable(data.frame()))
    if (is(res, "GRanges")) {
      DT::datatable(grToDf(res), options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
    } else if (is(res, "IRanges")) {
      DT::datatable(as.data.frame(res), options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
    } else {
      DT::datatable(data.frame(value = res), options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
    }
  })
}

shinyApp(ui, server)
