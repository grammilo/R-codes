####################################################################
# Track: Data Science Specialization                               #
# Course: Data Science Capstone                                    #
# University: John Hopkins                                         #
# Topic: Building a Text-Predicting R-Shiny App using Text Mining  #                                                    
#                                                                  #
# Author: Piyush Verma                                             #
# Start Date: 02/22/2018                                           #
####################################################################




####################################################################
# Necessary libraries
####################################################################
library(tm)
library(knitr)
library(stringi)
library(RWeka)
library(ggplot2)
library(stringdist)


####################################################################
# Reading files
####################################################################
t_line<-c()
t_words<-c()
max_words<-c()

files<-list.files(pattern = "en_US.")  
    for(i in 1:3){
      con<-file(files[i],open = "r")
      text<-suppressWarnings(readLines(con))
      # Counting total number of lines
      t_line[i]<-length(text) 
      # Counting total number of words
      t_words[i]<-sum(stri_count_words(text))   
      # Counting max number of words in 1 line
      max_words[i]<-max(stri_count_words(text)) 
      close(con)
    }
tab<-data.frame(Files = files[1:3], 
                Total_Lines = t_line, 
                Total_Words = t_words, 
                Max_Word = max_words)
# Output high level info for all the files
kable(tab[order(tab$Total_Lines,decreasing = TRUE),]) 



####################################################################
# Cleaning text files
####################################################################
final_text_combined<-NULL
for(i in 1:3){
              final_text_combined<-
              append(final_text_combined,
              suppressWarnings(readLines(file(files[i],open="r"))))
             }
all<-length(final_text_combined)
index<-sample(1:all,0.05*all)
combined_sample<-final_text_combined[index]


# This step removes 16% of bad characters like
# convert string to vector of words
dat2 <- unlist(strsplit(combined_sample, split=", ")) 
# Find indices of words with non-ASCII characters
dat3 <- grep("dat2", iconv(dat2, "latin1", "ASCII", sub="dat2")) 
# Subset original vector of words to exclude words with non-ASCII char
dat4 <- dat2[-dat3] 
# Convert vector back to a string
combined_sample <- paste(dat4, collapse = ", ") 

# Removing profanity words
profanityWords<-read.table("./profanity_filter.txt", header = FALSE)
removeURL<-function(x) gsub("http[[:alnum:]]*", "", x)
#mystopwords <- c("[Ii]","[Aa]nd", "[Ff]or","[Ii]n","[Ii]s",
#                 "[Ii]t","[Nn]ot","[Oo]n","[Tt]he","[Tt]o")



####################################################################
# Corpora Preparation
####################################################################
EN_corpora<-VCorpus(VectorSource(combined_sample), 
                    readerControl = list(language="en")
                    )

EN_corpora<-tm_map(EN_corpora, removeWords, stopwords('english'))
#EN_corpora<-tm_map(EN_corpora, removeWords, stopwords('SMART'))
#EN_corpora<-tm_map(EN_corpora, removeWords, stopwords('german'))
#EN_corpora<-tm_map(EN_corpora, removeWords, mystopwords)
EN_corpora<-tm_map(EN_corpora, content_transformer(
                                                    function(x) 
                                                    iconv(
                                                    x, to="UTF-8", sub="byte"
                                                    )
                                                  )
                   )
EN_corpora<-tm_map(EN_corpora, content_transformer(tolower))
EN_corpora<-tm_map(EN_corpora, content_transformer(removePunctuation),preserve_intra_word_dashes=TRUE)
EN_corpora<-tm_map(EN_corpora, removeWords, profanityWords$V1) #Profanity Filter
EN_corpora<-tm_map(EN_corpora, content_transformer(removeNumbers))
EN_corpora<-tm_map(EN_corpora, content_transformer(removeURL))
#EN_corpora<-tm_map(EN_corpora, stemDocument, language='english')
EN_corpora<-tm_map(EN_corpora, stripWhitespace)
EN_corpora<-tm_map(EN_corpora, PlainTextDocument)



####################################################################
# Exploratory Analysis
####################################################################

# Unigram Frequnecy Barplot
unigram<-NGramTokenizer(EN_corpora, Weka_control(min = 1, max = 1,delimiters = " \\r\\n\\t.,;:\"()?!"))
unigram<-data.frame(table(unigram))
unigram<-unigram[order(unigram$Freq,decreasing = TRUE),]
names(unigram)<-c("Word_1", "Freq")
unigram$Word_1<-as.character(unigram$Word_1)
p<-ggplot(data=unigram[1:10,], aes(x = reorder(Word_1,Freq), y = Freq, fill = Word_1))
p<-p + geom_bar(stat="identity") + coord_flip() + ggtitle("Frequent Words")
p<-p + geom_text(data = unigram[1:10,], aes(x = Word_1, y = Freq, label = Freq), hjust=-1, position = "identity")
p<-p + labs(x="Frequency",y="Words")
p

# Bigram Frequnecy Barplot
bigram<-NGramTokenizer(EN_corpora, Weka_control(min = 2, max = 2,delimiters = " \\r\\n\\t.,;:\"()?!"))
bigram<-data.frame(table(bigram))
bigram<-bigram[order(bigram$Freq,decreasing = TRUE),]
names(bigram)<-c("Word_1", "Freq")
bigram$Word_1<-as.character(bigram$Word_1)
q<-ggplot(data=bigram[1:10,], aes(x = reorder(Word_1,Freq), y = Freq, fill = Word_1))
q<-q + geom_bar(stat="identity") + coord_flip() + ggtitle("Frequent Words")
q<-q + geom_text(data = bigram[1:10,], aes(x = Word_1, y = Freq, label = Freq), hjust=-1, position = "identity")
q<-q + labs(x="Frequency",y="Words")
q

## Trigram Frequnecy Barplot
trigram<-NGramTokenizer(EN_corpora, Weka_control(min = 3, max = 3,delimiters = " \\r\\n\\t.,;:\"()?!"))
trigram<-data.frame(table(trigram))
trigram<-trigram[order(trigram$Freq,decreasing = TRUE),]
names(trigram)<-c("Word_1", "Freq")
trigram$Word_1<-as.character(trigram$Word_1)
r<-ggplot(data=trigram[1:10,], aes(x = reorder(Word_1,Freq), y = Freq, fill = Word_1))
r<-r + geom_bar(stat="identity") + coord_flip() + ggtitle("Frequent Words")
r<-r + geom_text(data = trigram[1:10,], aes(x = Word_1, y = Freq, label = Freq), hjust=-1, position = "identity")
r<-r + labs(x="Frequency",y="Words")
r

## Quadgram Frequnecy Barplot
quadgram<-NGramTokenizer(EN_corpora, Weka_control(min = 4, max = 4,delimiters = " \\r\\n\\t.,;:\"()?!"))
quadgram<-data.frame(table(quadgram))
quadgram<-quadgram[order(quadgram$Freq,decreasing = TRUE),]
names(quadgram)<-c("Word_1", "Freq")
quadgram$Word_1<-as.character(quadgram$Word_1)
s<-ggplot(data=quadgram[1:10,], aes(x = reorder(Word_1,Freq), y = Freq, fill = Word_1))
s<-s + geom_bar(stat="identity") + coord_flip() + ggtitle("Frequent Words")
s<-s + geom_text(data = trigram[1:10,], aes(x = Word_1, y = Freq, label = Freq), hjust=-1, position = "identity")
s<-s + labs(x="Frequency",y="Words")
s



####################################################################
# Splitting the words in quads for a later word by word match 
# with the user input 
####################################################################
quadgram$first  <- sapply(strsplit(quadgram$Word_1, split = " "),"[[",1)
quadgram$second <- sapply(strsplit(quadgram$Word_1, split = " "),"[[",2)
quadgram$third  <- sapply(strsplit(quadgram$Word_1, split = " "),"[[",3)
quadgram$fourth <- sapply(strsplit(quadgram$Word_1, split = " "),"[[",4)

trigram$first  <- sapply(strsplit(trigram$Word_1, split = " "),"[[",1)
trigram$second <- sapply(strsplit(trigram$Word_1, split = " "),"[[",2)
trigram$third  <- sapply(strsplit(trigram$Word_1, split = " "),"[[",3)

bigram$first  <- sapply(strsplit(bigram$Word_1, split = " "),"[[",1)
bigram$second <- sapply(strsplit(bigram$Word_1, split = " "),"[[",2)

unigram$first  <- sapply(strsplit(unigram$Word_1, split = " "),"[[",1)



####################################################################
# Save files as RDS
####################################################################
write.csv(unigram,"./unigram.csv",row.names = FALSE)
write.csv(bigram,"./bigram.csv",row.names = FALSE)
write.csv(trigram,"./trigram.csv",row.names = FALSE)
write.csv(quadgram,"./quadgram.csv",row.names = FALSE)

unigram_2<-read.csv("unigram.csv",stringsAsFactors = F)
bigram_2<-read.csv("bigram.csv",stringsAsFactors = F)
trigram_2<-read.csv("trigram.csv",stringsAsFactors = F)
quadgram_2<-read.csv("quadgram.csv",stringsAsFactors = F)

saveRDS(unigram_2,"./unigram.RData")
saveRDS(bigram_2,"./bigram.RData")
saveRDS(trigram_2,"./triigram.RData")
saveRDS(quadgram_2,"./quadgram.RData")


####################################################################
# Building the predict function
# Backoff model
####################################################################
Predict <- function(x){
  
        # "\\s+" is for space
        x<-strsplit(as.character(x), split = "\\s+")[[1]]
        # Preparation of the user input: Splitting and Cleaning
        x<-removeNumbers(removePunctuation(tolower(x))) 
        
        
        ## Back off algorithm
        if (length(x) >=3) {
                              x<-tail(x,3)
                              if (identical(character(0),head(quadgram[quadgram$first == x[1] & quadgram$second == x[2] & quadgram$third == x[3],"fourth"],1)))
                              {
                              Predict(paste(x[2],x[3],sep = " "))
                              }
                              else
                              {
                              display<-"Predicting word using the most popular four letter sentence"
                              head(quadgram[quadgram$first == x[1] & quadgram$second == x[2] & quadgram$third == x[3],"fourth"],1)
                              }
        }
        
        
        else if (length(x) ==2) {
                              x<-tail(x,2)
                              if (identical(character(0),head(trigram[trigram$first == x[1] & trigram$second == x[2],"third"],1)))
                              {
                              Predict(x[3])
                              }
                              else
                              {
                              display<-"Predicting word using the most popular three letter sentence"
                              head(trigram[trigram$first == x[1] & trigram$second == x[2],"third"],1)
                              }
        }
            
        
        else if (length(x) ==1) {
                              x<-tail(x,1)
                              if (identical(character(0),head(bigram[bigram$first == x[1],"second"],1)))
                              {
                              display<-"No match found !!! Please type some other word"
                              }
                              else
                              {
                              display<-"Predicting word using the most popular two letter sentence"
                              head(bigram[bigram$first == x[1],"second"],1)
                              }
        }
        
}

test<-"I will"
Predict(test)
