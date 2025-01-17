######### Short solution practice assignment ######

# setwd("~/your data folder")
diet=read.table("data/diet.txt",header=T)
colnames(diet)
pairs(diet[-c(1,2,6)])
xtabs(~gender,data=diet)
sum(diet$gender==0,na.rm=T) #43 number of females
sum(diet$gender==1,na.rm=T) #33 number of males
mean(diet$height[diet$gender==0],na.rm=T) # 167.3488
mean(diet$height[diet$gender==1],na.rm=T) # 175.2424

## a)
x=diet$preweight;y=diet$weight6weeks
# we intend to use paired t-test, then check normality
par(mfrow=c(1,2))
qqnorm(x);hist(x) # does not look normal
qqnorm(y);hist(y) # does not look normal
qqnorm(y-x);hist(y-x) #shapiro.test(y-x) # but the difference is actually ok
t.test(x,y,alt="g",paired=T) # p-value<2.2e-16, test says diet works  
## The samples x, y do not look normal, we can also use Mann-Whitney test  
# wilcox.test(x,y,paired=T) # p-value=1.372e-13, also this test says diet works 
# one can set in wilcoxon test alt="g", but it's fine without

## Remark. However if we test for the normality of the differences y-x, 
## they do look normal and the paired t-test can be applied.
## Thus full points are given also if normality is checked and confirmed 
## for y-x, and then paired t-test is applied. 


## b)
diet$weight.lost=diet$preweight-diet$weight6weeks
# We reduce the testing problem to a binomial test, let X be the lost weight.  
# Notice that H0: med(X)<= 3 against H1: med(X)>3 is the same as
# H0: p=P(X>3)<=0.5 against H1: p>0.5  
# The latter is a binomal test. So, 
n=length(diet$weight.lost); w=sum(diet$weight.lost>3)
binom.test(w,n,0.5,alt="g")
# p-value=0.04439<0.05, we reject H0, hence the claim med(X)>3 is correct.

## c)
diet$diet=factor(diet$diet) # make the variable diet factor
## is.factor(diet$diet) # just to check that it became factor
mod1=lm(weight.lost~diet,data=diet)
anova(mod1) ## p=0.003229, diet has an effect on the lost wight
par(mfrow=c(1,2)) # check the normality assumption
qqnorm(residuals(mod1)) # looks ok
plot(fitted(mod1),residuals(mod1)) # looks ok, remember there are just 3 fitted values

## Do all three types of diets lead to weight loss?
summary(mod1)
# Yes, as all cell means mu+alpha_i>0 are positive.
# Which diet was best for losing weight? Diet 3 is the best

## d)
# Test for interaction between gender and diet
mod2=lm(weight.lost~gender*diet,data=diet)  
anova(mod2) # interaction between gender and diet is barely present (p-value=0.048842)
## it seems that diet is certainly significant, 
# gender is present as well at least via interaction which is significant 
 
# Why cannot we apply the Friedman test? 
# One simple (but not full) answer is: the Friedman test is not relevant 
# because there is no block factor involved here. We can pretend that gender 
# is block, the test still cannot be applied in view of the wrong design

# Additional reasoning why the Friedman test is not relevant. If we try
friedman.test(diet$weight.lost,diet$diet,diet$gender) 
# we see the problems with NA's
diet2=diet[-c(25,26),] # but even if we remove the rows with NA's, there will 
# still be a problem with the wrong design: we do not have one observation 
# for all combinations of levels of the treatment and block factors
friedman.test(diet2$weight.lost,diet2$diet,diet2$gender) # wrong design

## e)
is.numeric(diet$height) # just to check height is numeric
mod4=lm(weight.lost~diet*height,data=diet)
anova(mod4) # p-value=0.286928, no interaction between diet and height
## Is the effect of height the same for all 3 types of diet?
# Yes, because there is no interaction between diet and height. 
# Now we test for the main effects by using the additive model 
drop1(lm(weight.lost~diet+height,data=diet),test="F")
# diet p-value=0.005612, height p-value=0.831170
# conclude that diet is significant and height is not. 

## f)
# In e) we found there is no interaction. So we use the additive model
mod5=lm(weight.lost~diet+height,data=diet)
drop1(mod5,test="F") # factor diet is significant, variable height is not
## not asked: also summary(mod5) # confirms what we had in c)

# Hence the approach from c) is preferable (with only factor diet): 
# no reason to include variable height that has no effect whatsoever. 

# Prediction of the lost weight for all 3 types of diet for an average person:
# the characteristics of a person do not matter as they are not included 
# in our preferred model (just one-way anova with factor diet)
summary(mod1) # and compute the group means: 3.3000kg, 3.3000-0.2741=3.0259kg, 
# 3.3000+1.8481=5.1481kg are expected to loose as result of diets 1,2,3
# Alternatively, by predict command:
newdata=data.frame(diet=c("1","2","3"))
predict(mod1,newdata) # 3.300000kg 3.025926kg 5.148148kg 
 

## g) 
# Test in b) is impossible to implement

# Test in c) for lost.4kg and diet can be done in two ways:  
# either by contingency table test; or by using logistic regression.
# Any of the two is ok. We use logistic regression for the test in c).

# Test in c) by logistic regression lost.4kg~diet
lost.4kg=diet$weight.lost>4
lr1=glm(lost.4kg~diet,family=binomial,data=diet)
anova(lr1,test="Chisq") # p-value=0.003409, diet is significant

# Tests in d) and e) can be addressed by the logistic regression
## Test in d) by logistic regression lost.4kg~diet*gender
lr3=glm(lost.4kg~gender*diet,family=binomial,data=diet)
anova(lr3,test="Chisq") # p-value=0.010035, interaction between diet and gender
 
# Test in e) by logistic regression lost.4kg~diet*height
lr5=glm(lost.4kg~diet*height,family=binomial,data=diet)
anova(lr5,test="Chisq") # p-value=0.504096, no interaction between diet and height
lr6=glm(lost.4kg~diet+height,family=binomial,data=diet) # additive model
drop1(lr6,test="Chisq")  # diet p-value=0.004247, height p-value=0.872770 
# diet is significant, height is not




 