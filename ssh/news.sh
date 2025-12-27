export romeurl="https://www.northwestgeorgianews.com";
export homepage=${romeurl}'/rome/';


mkdir -p articles;

#clear old articles
rm articles/*.html;
rm articles/*.pdf;

#pull and download list of unique news urls linked from home page
curl $homepage > articles/romenews.html

#grep "\/news\/" articles/romenews.html | \
grep -E "\/news\/|article_" articles/romenews.html | \
   grep html | \
      grep -Ev '</(time)>' | \
         grep -Eo 'href="[^\"]+"' | \
            cut -d \" -f2  | \
               awk '!seen[$0]++' | \
                  awk -v romeurl="$romeurl" -F / '{ print \
                    "curl \"" romeurl $0 "\" | sed -e \"s/display:none//g\" -e \"s/\<template/\<demplate/g\" -e \"s/\<base/\<face/g\" -e \"/enterprise.js/d\" -e \"s/\\\<\\\/html\/\\\<script src=\\\"..\\\/news.js\\\" type=\\\"text\\\/javascript\\\"\>\<\\\/script\>\<\\\/html/g\" > articles/" $(NF-1) ".html" }' | \
                       awk '{system($0)}'




                    #"curl \"" romeurl $0 "\" | sed -e \"s/display:none//g\" -e \"s/\<template/\<demplate/g\" -e \"/enterprise.js/d\" > articles/" $(NF-1) ".html" }' | \
# 1.) grep the homepage for /news/
#    2.) grep those results for html articles  
#        for each news html article in the homepage:
#       3.)  awk - pull everything between the quotation marks in the news html url reference line 
#            print a curl command that pulls the full html news article
#            4.)  remove display:none to prevent hiding article content
#                 direct the output of that article to a local file with a name based on the source html's reference to it.  
#                 5.)  awk to remove any duplicates in the list of curl commands u
#                      6.)  awk to remove unncesaary parts of the url path in the local file name being used in part 4.) 
#                           7.)  awk to execute each curl command in our list of curl commands 


# next let's update the "Date Modified" for each html file based on the contents
grep -Eo 'published_time\":"[^\"]+"' articles/*.html | awk -F : '{print "TZ=UTC touch -m -t " $3 $4  " " $1 }' | cut -c 1-12,13-19,21-24,26-27,29-30,32- | awk '{system($0)}'


echo "made it here"; 

#archive process
#outputDate="$(date +"%Y-%m-%d-%H")";
outputDate="$(date +"%Y-%m-%d")"; #removing hour from directory for testing
mkdir -p articles/archives/;
mkdir -p articles/arrestreports/;
mkdir -p articles/archives/all/;
mkdir -p articles/archives/$outputDate;
cp -p articles/*.html articles/archives/$outputDate/
cp -p articles/*.html articles/archives/all/


echo "made it here 2"; 

cd articles
grep bloximages *.html | grep pdf | grep -Eo 'href="[^\"]+"' | cut -d \" -f2 | sed 's/.pdf.*/.pdf.pdf/' | awk '!seen[$0]++' | xargs -n 1 curl -O


cp -p *.pdf arrestreports/

#notes and milestones from development cycle:  

#without linebreaks...
#grep "\/news\/" articles/romenews.html | grep html |  grep -Ev '</(time)>' | grep -Eo 'href="[^\"]+"' | cut -d \" -f2  | awk '!seen[$0]++' | awk -F / '{ print "curl \"https://www.northwestgeorgianews.com" $0 "\" | sed -e \"s/display:none//g\" -e \"s/\<template/\<demplate/g\" -e \"/enterprise.js/d\" > articles/" $(NF-1) ".html" }' | awk '{system($0)}'

# touch -d "2012-10-19 12:12:12.000000000 +0530" tgs.txt

#sed -n 's/subscriber-only"\(.*\)<\/div>/\1/Ip' *.html

#grep "\/news\/" romenews.html | grep html | awk -F '"' '{print "https://www.northwestgeorgianews.com" $2}' | awk '!seen[$0]++' 

#| grep -Po '(?<=<subscriber-only>).*(?=</subscriber-only>)'

#awk -F '"' '{print "https:\/\/www.northwestgeorgianews.com",$2} '

#sed -n 's/<title>\(.*\)<\/title>/\1/Ip' articles/*.html
#grep "\/news\/" romenews.html | grep html | awk -F '"' '{print "https:\/\/www.northwestgeorgianews.com",$2}' | awk '!seen[$0]++'

#grep "\/news\/" romenews.html | grep html | awk -F '"' '{print "curl https:\/\/www.northwestgeorgianews.com",$2,"-o " $2}' | awk '!seen[$0]++' | sed 's/.com /.com/g'

#grep "\/news\/" romenews.html | grep html | awk -F '"' '{print "curl -J -O https://www.northwestgeorgianews.com" $2}'

#grep "\/news\/" romenews.html | grep html | awk -F '"' '{print "https:\/\/www.northwestgeorgianews.com",$2}' | awk '!seen[$0]++' | sed 's/ //g'  xargs curl -O

#grep "\/news\/" romenews.html | grep html | awk -F '"' '{print "curl https://www.northwestgeorgianews.com" $2 " > articles" $2}' | awk '!seen[$0]++'

#grep "\/news\/" romenews.html | grep html | awk -F '"' '{print "curl https://www.northwestgeorgianews.com" $2 " > articles" $2}' | awk '!seen[$0]++' | awk -F / '{ print $1 $(NF-1) }'
 
#grep "\/news\/" articles/romenews.html | grep html | grep -Ev '</(time)>'

#grep "\/news\/" articles/romenews.html | grep html |  grep -Ev '</(time)>' | grep -Eo 'href="[^\"]+"' | cut -d \" -f2

#grep "\/news\/" articles/romenews.html | grep html |  grep -Ev '</(time)>' | awk -F '"' '{print "curl https://www.northwestgeorgianews.com" $2 " | sed s/display\:none//g > articles" $2}' | awk '!seen[$0]++' | awk -F / '{ print $1"//" $3"/" $4 "/"$5"/" $6"/" $7"/" $8 "/" $9 "/" $10 "/" $11 "/" $(NF-1) ".html" }'  | awk '{system($0)}'

#grep "\/news\/" articles/romenews.html | grep html |  grep -Ev '</(time)>' | grep -Eo 'href="[^\"]+"' | cut -d \" -f2 | awk -F '"' '{print "curl https://www.northwestgeorgianews.com" $1 " | sed s/display\:none//g > articles" $1}' | awk '!seen[$0]++' | awk -F / '{ print $1"//" $3"/" $4 "/"$5"/" $6"/" $7"/" $8 "/" $9 "/" $10 "/" $11 "/" $(NF-1) ".html" }' | awk '{system($0)}'

#awk 'BEGIN{RS="\/article_"; FS="rome\/news"}NF>1{print $NF}'

#grep "\/news\/" articles/romenews.html | grep html |  grep -Ev '</(time)>' | grep -Eo 'href="[^\"]+"' | cut -d \" -f2 | awk 'BEGIN{RS="\/article_"; FS="\/"}NF>1{print $NF}'

#grep "\/news\/" articles/romenews.html | grep html |  grep -Ev '</(time)>' | grep -Eo 'href="[^\"]+"' | cut -d \" -f2 | awk '{print "curl \"https:\/\/www.northwestgeorgianews.com" $NF "\" > " $NF}'

#grep "\/news\/" articles/romenews.html | grep html |  grep -Ev '</(time)>' | grep -Eo 'href="[^\"]+"' | cut -d \" -f2 | awk -F '"' '{print "curl https://www.northwestgeorgianews.com" $1 " | sed s/display\:none//g > articles" $1}' | awk '!seen[$0]++' | awk -F "/" 'BEGIN{OFS="/"} { print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11 "/" $(NF-1) ".html" }' | awk '{system($0)}'

#grep -E "\/news\/|article_" articles/romenews.html | awk -F / '{ print "articles/" $(NF-1) ".html" }'
#sed 's|<a[^>]* href="[^"]*/|<a href="http://www.someurl.com/|g' romenews.html
#awk -F / '{ print $(NF-1) }'
#this one works!!!   sed -r 's|<a[^>]* href=".*/([^/]*)/[^/]*$|<a href="\1.html">|g' romenews.html > bomenews.html

#grep bloximages *.html | grep jpg | grep -Eo 'srcset="[^\"]+"' | cut -d \" -f2 | sed 's/.jpg.*/.jpg/' | xargs -n 1 curl -O


#ROT-47 Cipher
