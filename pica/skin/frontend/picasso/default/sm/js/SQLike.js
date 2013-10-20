﻿/*

SQLike version 1.02
[JavaScript]/ActionScript 2/ActionScript 3-based SQL-like query engine
copyright 2010 Thomas Frank

This EULA grants you the following rights:

Installation and Use. You may install and use an unlimited number of copies of the SOFTWARE PRODUCT.

Reproduction and Distribution. You may reproduce and distribute an unlimited number of copies of the SOFTWARE PRODUCT either in whole or in part; each copy should include all copyright and trademark notices, and shall be accompanied by a copy of this EULA. Copies of the SOFTWARE PRODUCT may be distributed as a standalone product or included with your own product.

Commercial Use. You may sell for profit and freely distribute scripts and/or compiled scripts that were created with the SOFTWARE PRODUCT.

*/

SQLike={q:function(B){var aQ,aP,aO,aM,aK,aJ,aI,aH,aG,aF,aE,aD,aC,aB,az,ay,ax,aw,av,au,at,ar,aq,ao,an,al,D,aA,M,ak,am,ab,ai,Y,L,P,aN,aa,ad,aL,X,Z,G,ah,T,E,S,R,ac,A,J,I,U,V,N,F,ag,af,ap,W,Q,ae,C,H,K,aj,O;if(arguments.length>1){aQ=arguments,aw=ac;for(aG=0;aG<aQ.length;aG++){aw=arguments.callee(aQ[aG])}return aw}az={};for(aG in B){az[aG.toUpperCase().split("_").join("")]=B[aG]}if(az.DELETE&&az.FROM){az.DELETEFROM=az.FROM}F=!!az.UNIONDISTINCT+!!az.UNION+!!az.UNIONALL+!!az.INTERSECTDISTINCT+!!az.INTERSECT+!!az.INTERSECTALL+!!az.MINUS+!!az.EXCEPTDISTINCT+!!az.EXCEPT+!!az.EXCEPTALL;if(F+!!az.SELECT+!!az.SELECTDISTINCT+!!az.INSERTINTO+!!az.UPDATE+!!az.DELETEFROM+!!az.UNPACK+!!az.PACK!=1){return[]}else{if(az.TESTSUB){return"issub"}}aM=(az.SELECT||az.SELECTDISTINCT)?az.FROM:az.INSERTINTO||az.UPDATE||az.DELETEFROM||az.PACK||az.UNPACK,A=aM;if(aM&&typeof aM=="object"&&!aM.push){J={TESTSUB:true};for(aG in aM){J[aG]=aM[aG]}if(arguments.callee(J)=="issub"){aM=arguments.callee(aM)}}if(az.LIMIT){ao=az.LIMIT;az.LIMIT=ac;return arguments.callee(az).slice(0,ao)}if(az.INTO&&az.INTO.push){U=az.INTO;az.INTO=ac;U.splice.apply(U,[U.length,0].concat(arguments.callee(az)));return U}if(az.INSERTINTO){aM.push(az.VALUES);return aM}if(F){aj={f:function(s,aU){var n=[],l,m,r=[],aR={},t={},y={},u,s,p,b={},g,c,aT=[],aS=s.UNIONDISTINCT||s.UNION||s.UNIONALL||s.INTERSECTDISTINCT||s.INTERSECT||s.INTERSECTALL||s.MINUS||s.EXCEPTDISTINCT||s.EXCEPT||s.EXCEPTALL,q=aS.length;for(var e in s){if(s[e]===aS){var v=e.toUpperCase();l=v.split("ALL").length>1;m=v.split("UNION").length>1?1:v.split("INTERSECT").length>1?2:3;if(v=="MINUS"){m=3;l=false}}}for(var w=0;w<aS.length;w++){r.push(aU(aS[w]))}for(w=0;w<q;w++){for(v in r[w][0]){if(!aR[v]){aR[v]=0}aR[v]++}}for(w in aR){if(aR[w]==q){t[w]=true}}for(w=0;w<q;w++){for(v=0;v<r[w].length;v++){s={},p=[];for(u in t){s[u]=r[w][v][u];p.push(r[w][v][u])}p=p.join("|||");n.push(s);if(!b[p]){b[p]=[]}b[p].push({indexNo:n.length-1,tableNo:"t"+w})}}if(m==1&&l){return n}for(w in b){g={},c=0;for(v=0;v<b[w].length;v++){g[b[w][v].tableNo]=true}for(v in g){c++}for(v=0;v<b[w].length;v++){if((m==2&&c!=q)||(m==3&&(c!=1||g.t1))||(!l&&v>0)){aT[b[w][v].indexNo]=true}}}for(w=n.length-1;w>=0;w--){if(aT[w]){n.splice(w,1)}}return n}};return aj.f(az,arguments.callee)}if(az.UNPACK){aO=az.COLUMNS;if(!aO){return false}for(aG=0;aG<aM.length;aG++){az={};for(aF=0;aF<aO.length;aF++){az[aO[aF]]=aM[aG][aF]}aM[aG]=az}return aM}if(az.PACK){if(!az.COLUMNS){az.COLUMNS=[];for(aG in aM[0]){az.COLUMNS.push(aG)}}aO=az.COLUMNS;for(aG=0;aG<aM.length;aG++){aQ=[];for(aF=0;aF<aO.length;aF++){aQ[aF]=aM[aG][aO[aF]]}aM[aG]=aQ}return aM}if(az.ORDERBY&&!az.ORDERBY.prep){az.ORDERBY.prep=true;ao=arguments.callee(az),M=[];if(az.GROUPBY){ao=[ao,ao]}for(aG=0;aG<ao[0].length;aG++){aQ={},Y=0;for(aF in ao[0][aG]){Y++;aQ[aF]=ao[0][aG][aF]}for(aF in ao[1][aG]){Y++;if(aQ[aF]===ac){aQ[aF]=ao[1][aG][aF]}}aQ.__sqLikeSelectedData=ao[0][aG];M.push(aQ)}ak={a:[],d:[]},aQ=az.ORDERBY||[],aJ;ao=ak;for(aG=0;aG<aQ.length;aG++){if(aQ[aG]=="|desc|"||aQ[aG]=="|asc|"){continue}ao.d.push(aQ[aG+1]=="|desc|"?-1:1);ao.a.push(aQ[aG])}M.sort(function(a,b){aQ=ak.a;aM=ak.d;aw=0;for(aG=0;aG<aQ.length;aG++){if(typeof a+typeof b!="objectobject"){return typeof a=="object"?-1:1}aC,aB;if(typeof aQ[aG]=="function"){aC=aQ[aG].apply(a);aB=aQ[aG].apply(b)}else{aC=a[aQ[aG]];aB=b[aQ[aG]]}if((aC===true||aC===false)&&(aB===true||aB===false)){aC*=-1;aB*=-1}aw=aC-aB;if(isNaN(aw)){return aC>aB?1:aC<aB?-1:0}if(aw!=0){return aw*aM[aG]}}return aw});aw=[];for(aG=0;aG<M.length;aG++){aw.push(M[aG].__sqLikeSelectedData)}return aw}if(az.HAVING){am=az.HAVING;az.HAVING=ac;ao=arguments.callee(az);aw=arguments.callee({SELECT:["*"],FROM:ao,WHERE:am});return aw}if(az.GROUPBY){au=[],ax={SELECTDISTINCT:az.GROUPBY,FROM:az.FROM,WHERE:az.WHERE};aI=arguments.callee(ax);for(aG=0;aG<aI.length;aG++){ax={};for(aF in az){ax[aF]=az[aF]}ax.GROUPBY=ax.ORDERBY=ac;V=az.WHERE||function(){return true};N=aI[aG];ax.WHERE=function(){var a=V.apply(this);for(var b in N){a=a&&this[b]==N[b]}return a};au.push(arguments.callee(ax)[0])}return au}az.JOIN=az.JOIN||az.INNERJOIN||az.NATURALJOIN||az.CROSSJOIN||az.LEFTOUTERJOIN||az.RIGHTOUTERJOIN||az.LEFTJOIN||az.RIGHTJOIN||az.FULLOUTERJOIN||az.OUTERJOIN||az.FULLJOIN;if(az.NATURALJOIN||az.USING){for(aF in az.JOIN){if(!aM[aF]){aM[aF]=az.JOIN[aF]}}aJ={},H=[],K=0;for(aG in aM){K++;for(aF in aM[aG][0]){if(!aJ[aF]){aJ[aF]=0}aJ[aF]++}}for(aG in aJ){if(aJ[aG]==K){H.push(aG)}}az.USING=az.USING||H,aP={};for(aG=0;aG<az.USING.length;aG++){aP[az.USING[aG]]=true}for(aG in aM){ao=aM[aG];aM[aG]=[];for(aE=0;aE<ao.length;aE++){J={},aH=[];for(aF in ao[aE]){J[aF]=ao[aE][aF]}for(aF=0;aF<az.USING.length;aF++){aH.push(ao[aE][az.USING[aF]])}J.__SQLikeHash__=aH.join("|");aM[aG][aE]=J}}az.ON=function(){var c=arguments.callee;if(c.LEN==2){return this[c.TABLELABEL[0]].__SQLikeHash__==this[c.TABLELABEL[1]].__SQLikeHash__?c.USINGOBJ:false}if(c.LEN==3){return this[c.TABLELABEL[0]].__SQLikeHash__==this[c.TABLELABEL[1]].__SQLikeHash__&&this[c.TABLELABEL[0]].__SQLikeHash__==this[c.TABLELABEL[2]].__SQLikeHash__?c.USINGOBJ:false}var b=this[c.TABLELABEL[0]].__SQLikeHash__;for(var d in this){if(this[d].__SQLikeHash__!=b){return false}}return c.USINGOBJ};az.ON.TABLELABEL=[];for(aG in aM){az.ON.TABLELABEL.push(aG)}az.ON.USINGOBJ=aP;az.ON.LEN=K;az.NATURALJOIN=az.USING=ac}if(az.CROSSJOIN){az.ON=function(){return true};az.CROSSJOIN=false}if(az.JOIN&&az.ON&&!aM.join&&!az.JOIN.join){for(aF in az.JOIN){if(!aM[aF]){aM[aF]=az.JOIN[aF]}}ab={},aE;for(aF in aM){if(az.FULLOUTERJOIN||az.FULLJOIN||az.OUTERJOIN){aE=true;ab[aF]=true}if((az.LEFTOUTERJOIN||az.LEFTJOIN)&&!az.JOIN[aF]){aE=true;ab[aF]=true}if((az.RIGHTOUTERJOIN||az.RIGHTJOIN)&&az.JOIN[aF]){aE=true;ab[aF]=true}}az.OUTERTABLES=aE?ab:false;aJ=az.WHERE||function(){return true};az.WHERE=az.ON;az.WHERE.org=aJ;az.JOIN=az.INNERJOIN=az.NATURALJOIN=az.CROSSJOIN=az.LEFTOUTERJOIN=az.RIGHTOUTERJOIN=az.LEFTJOIN=az.RIGHTJOIN=az.FULLOUTERJOIN=az.OUTERJOIN=az.FULLJOIN=az.ON=ac;return arguments.callee(az)}if(!aM.join){O={f:function(l,g,n){var j=[],i=[],b=[],k=[],h=[],f=0,c=[];for(aG in l){b.push(l[aG].length);h.push(aG);c.push([]);k.push(0);f++}while(k[f-1]<b[f-1]){var a={};for(aG=0;aG<f;aG++){a[h[aG]]=l[h[aG]][k[aG]]}ax=g.apply(a);if(ax){if(n){for(aG=0;aG<f;aG++){c[aG][k[aG]]=true}}B={};for(aG=0;aG<f;aG++){for(aF in a[h[aG]]){if(aF=="__SQLikeHash__"){continue}B[(typeof ax=="object"&&ax[aF]?"":h[aG]+"_")+aF]=a[h[aG]][aF]}}j.push(B);i.push(a)}for(aG=0;aG<f;aG++){k[aG]++;if(k[aG]<b[aG]){break}if(aG<f-1){k[aG]=0}}}if(n){for(aG=0;aG<f;aG++){if(!n[h[aG]]){continue}for(aF=0;aF<b[aG];aF++){if(!c[aG][aF]){a=l[h[aG]][aF],J={},I={};for(aE=0;aE<f;aE++){I[h[aE]]={}}for(aE in a){I[h[aG]][aE]=a[aE];J[h[aG]+"_"+aE]=a[aE]}j.push(J);i.push(I)}}}}if(g.org){for(aG=j.length-1;aG>=0;aG--){if(!g.org.apply(i[aG])){j.splice(aG,1)}}}return j}};aM=O.f(aM,az.WHERE,az.OUTERTABLES)}else{aA=[],aN=[];for(aG=0;aG<aM.length;aG++){if(!az.WHERE||az.WHERE.apply(aM[aG])){aA.push(aM[aG]);aN.push(aG)}}aM=aA}if(az.DELETEFROM){for(aG=aN.length-1;aG>=0;aG--){A.splice(aN[aG],1)}return A}if(az.UPDATE&&az.SET){for(aG=0;aG<=aN.length;aG++){az.SET.apply(A[aN[aG]])}return A}aa=!!az.SELECTDISTINCT;az.SELECT=az.SELECT||az.SELECTDISTINCT;if(az.SELECT&&az.SELECT.length>0){aA=[],ad={},aL={},X=0,av=az.SELECT;if(av[0]=="|count|"&&av[1]=="*"){return[{count:aM.length}]}for(aG=0;aG<av.length;aG++){if(av[aG]=="*"){aH={},au=[];for(aE=0;aE<aM.length;aE++){for(aF in aM[aE]){if(!aH[aF]){au.push(aF);aH[aF]=true}}}av.splice(aG,1);for(aF=au.length-1;aF>=0;aF--){av.splice(aG,0,au[aF])}break}}for(aG=0;aG<aM.length;aG++){Z,B={},G;for(aF=0;aF<av.length;aF++){ah=av[aF],T=ah,E=aM[aG][T];if(typeof av[aF]=="string"&&av[aF].toLowerCase()=="|as|"){aF+=1;continue}if(typeof av[aF]=="string"&&av[aF].charAt(0)=="|"&&av[aF].charAt(av[aF].length-1)=="|"){continue}if(typeof ah=="function"){E=ah.apply(aM[aG]);Y=1;ah="udf_1";while(B[ah]){Y++;ah="udf_"+Y}}if(typeof av[aF+1]=="string"&&typeof av[aF+2]=="string"&&av[aF+1].toLowerCase()=="|as|"){ah=av[aF+2]}if(typeof av[aF-1]=="string"&&av[aF-1].charAt(0)=="|"&&av[aF-1].charAt(av[aF-1].length-1)=="|"){S=av[aF-1].split("|")[1];ah=S+"_"+ah;aL[ah]={type:S,count:0,sum:0,avg:0}}if(az.JHELP&&!az.JHELP[ah]){ah=az.JTNAME+ah}Z=ah;B[ah]=E;if(aG==0){X++}}if(aa){ao=[];for(aE in B){ao.push(B[aE])}G=ao.join("|||")}if(!aa||!ad[G]){aA.push(B)}if(aa){ad[G]=true}}R=0;for(aG in aL){R++;an=aL[aG];for(aF=0;aF<aA.length;aF++){ao=aA[aF][aG];if(ao!==ac){an.count++;if(an.min===ac){an.min=ao}if(an.max===ac){an.max=ao}if(an.min>ao){an.min=ao}if(an.max<ao){an.max=ao}if(ao/1==ao){an.sum+=ao}}}an.avg=an.sum/an.count;aA[0][aG]=aL[aG][aL[aG].type]}if(R>0){aA=[aA[0]];aM=[aA[0]]}if(az.ORDERBY&&az.ORDERBY.prep){return[aA,aM]}return aA}return[]}};