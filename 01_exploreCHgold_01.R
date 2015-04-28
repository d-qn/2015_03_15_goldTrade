source("~/swissinfo/_helpers/helpers.R")
library(swiTheme)
library(dplyr)

############################################################################################
###   SETTINGS
############################################################################################

# the path to the data file with 1982-2014 data merged
mergedFile <- '/data/1982_2014_gold_bound-tsv.tsv'


datafile <- 'data/1982-bis-2013_E-copy-csv.tsv'
datafile_2014 <- 'data/2014_gold-xlsx.tsv'


############################################################################################
###   Load indicators
############################################################################################

if(mergedFile != '') {
	data.read <- read.csv(datafile, sep ="\t", stringsAsFactors = F)

	## remove empty rows
	data.read <- data.read[which(!data.read$trade == '' & !is.na(data.read$value)),]

	## check 'total trade' partner is equal to the sum of all countries

	invisible(by(data.read, list(data.read$Year, data.read$trade, data.read$type), function(dd) {
		if(!sum(dd[dd$Partner != 'Total Trade','value']) == dd[dd$Partner == 'Total Trade','value']) {
			print(paste("SUM:", sum(dd[dd$Partner != 'Total Trade','value']), "vs Total trade",
			dd[dd$Partner == 'Total Trade','value']))
		}
	}))
	# data without 'total trade'
	data <- dplyr::filter(data.read, Partner != 'Total Trade')

	#####   Load the recent data file!! ############
	data2.read <- read.csv(datafile_2014, sep ="\t", stringsAsFactors = F)

	data <- rbind(data, data2.read)
	write.table(data, file = "data/1982_2014_gold_bound.tsv", sep = "\t", row.names = F)

	### open google refine and cluster country names and saved it as mergedFile
} else {
	data <- read.csv(mergedFile, sep ="\t", stringsAsFactors = F)
}


# replace USSR & Russian Fed by <- "USSR/Russia"
data[which(data$Partner %in% c("USSR", "Russian Federation")),'Partner'] <- "USSR/Russia"


# compute the yearly total
by_ytt <- group_by(data, Year, trade, type)
data <- mutate(by_ytt, total = sum(value))
data.tot <- summarise(by_ytt, TotalTrade = sum(value))
# express the total in billions CHF and tons of gold
data.tot[which(data.tot$type == "CHF"),]$TotalTrade  <- data.tot[which(data.tot$type == "CHF"),]$TotalTrade / 10^9

data.tot[which(data.tot$type == "KG"),]$TotalTrade  <- data.tot[which(data.tot$type == "KG"),]$TotalTrade / 10^3


############################################################################################
###   Plot
############################################################################################

# Plot the total trade over time
ggplot(data = dplyr::filter(data.read, Partner == 'Total Trade'), aes(Year, value)) + geom_line() +
	facet_grid(type ~ trade , scales = "free") + swiTheme::theme_swi()




############################################################################################
###   ###   --- PROD CHART 1 total gold import & export 	--- ###
############################################################################################


# with recend data bound (with 2014 data)

## customize look
gp.look <- list(
	# scales
	scale_x_continuous("", limits = c(min(data.tot$Year),max(data.tot$Year)), expand = c(0.0,0.0)),
	scale_y_continuous(expand = c(0.0,0), breaks = pretty_breaks(n = 3)),
 	theme(
		# horizontal grid lines
    	panel.grid.major.x = element_blank(),
		panel.grid.minor.x = element_blank(),
		panel.grid.minor.y = element_blank(),
		panel.grid.major.y = element_line(colour = "grey", size = 0.03, lineend = "round"),
		# remove y ticks
		axis.ticks.y = element_blank()
	),
	# veritcal white lines
	geom_vline(xintercept=seq(min(data.tot$Year),max(data.tot$Year), by = 1), color = "white", size = 0.07),
	# colors
	scale_fill_manual(values = swi_pal[c(1, 11)], guide = FALSE)
)

gp1 <- ggplot(data = filter(data.tot, trade == "import"), aes(Year, TotalTrade)) + geom_area(aes(fill = type)) +
	facet_wrap(type ~ trade , scales = "free_y", ncol = 1) + swiTheme::theme_swi2(base_size = 8.5) + gp.look

gp2 <- ggplot(data = filter(data.tot, trade == "export"), aes(Year, TotalTrade)) + geom_area(aes(fill = type)) +
	facet_wrap(type ~ trade , scales = "free_y", ncol = 1) + swiTheme::theme_swi2(base_size = 8.5) + gp.look

pdfswi_long("totalCHgold_trade.pdf")
multiplot(gp1, gp2, cols = 1)
dev.off()


############################################################################################
###   ###   --- PROD CHART 2 split by top country import & export	--- ###
############################################################################################

# for each year, trade, type : compute the percentage of total
by_ytt <- group_by(data, Year, trade, type)
perc <- ungroup(mutate(mutate(by_ytt, total = sum(value)), yearlyPerc = value / total))

# compute the perc of total not by year but overall by partner
tot <- summarise(group_by(data, trade, type, Partner), total = sum(value))
tot <- ungroup(mutate(tot, totPerc = total / sum(total)))



look2 <- list(
	# scales
	scale_x_continuous("", limits = c(min(data.tot$Year),max(data.tot$Year)), expand = c(0.0,0.0)),
	scale_y_continuous(expand = c(0.0,0), breaks = pretty_breaks(n = 3), labels = percent),
 	theme(
		# horizontal grid lines
    	panel.grid.major.x = element_blank(),
		panel.grid.minor.x = element_blank(),
		panel.grid.minor.y = element_blank(),
		panel.grid.major.y = element_line(colour = "grey", size = 0.03, lineend = "round"),
		# remove y ticks
		axis.ticks.y = element_blank()
	)
	# veritcal white lines
	#geom_vline(xintercept=seq(min(data.tot$Year),max(data.tot$Year), by = 1), color = "white", size = 0.07)
	# colors

)



# get the countries accouting for r.threshold % of the total weight import
r.threshold <- 0.03
tradetype <- 'import'

country.sub <- tot %>% filter(trade == tradetype, type == "KG", totPerc >= r.threshold) %>% select(Partner) %>% unlist
pOfTot <- tot %>% filter(Partner %in% country.sub, type == "KG", trade == tradetype) %>% summarise(sum(totPerc))


dd <- filter(perc, trade == tradetype, type == 'KG', Partner %in% country.sub)
ip <- ggplot(data = dd, aes(Year, yearlyPerc)) +
	geom_area(fill = swi_pal[19]) + facet_wrap(~ Partner, ncol = 2) + theme_swi2(base_size = 9) + look2

pdfswi_long("topGoldImport.pdf")
ip + ggtitle(paste(format(pOfTot, digits = 2)))
dev.off()



# get the countries accouting for r.threshold % of the total weight export
r.threshold <- 0.045
tradetype <- 'export'

country.sub <- tot %>% filter(trade == tradetype, type == "KG", totPerc >= r.threshold) %>% select(Partner) %>% unlist
pOfTot <- tot %>% filter(Partner %in% country.sub, type == "KG", trade == tradetype) %>% summarise(sum(totPerc))


dd <- filter(perc, trade == tradetype, type == 'KG', Partner %in% country.sub)
ep <- ggplot(data = dd, aes(Year, yearlyPerc)) +
	geom_area(fill = swi_pal[19]) + facet_wrap(~ Partner, ncol = 2) + theme_swi2(base_size = 9) + look2

pdfswi_long("topGoldExport.pdf")
ep + ggtitle(paste(format(pOfTot, digits = 2)))
dev.off()




