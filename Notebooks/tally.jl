##### Type : Tally
type Tally

  text:: String
  nobs:: Int64

  currentAverage:: Float64 # current observations average
  minValue:: Float64  # minimum of the observations
  maxValue:: Float64  # maximum of the observations
  sumValue:: Float64  # sum of the observations
  sumSquares:: Float64 # sum of the square of the observations
  currentSum2:: Float64 
        
  # Constructor definition
  function Tally(text::String)
    t = new()
    t.text = text
    init(t);
    return t
  end

end    
   
function init(t::Tally)
    t.nobs = 0
    t.minValue = Inf
    t.maxValue = -Inf
    t.sumValue = 0.0
    t.sumSquares = 0.0
    t.currentSum2 = 0.0
    t.currentAverage = 0.0
end

function add(t::Tally, x::Float64)

  if (x < t.minValue) 
    t.minValue = x
  end

  if (x > t.maxValue) 
    t.maxValue = x
  end
  
  # Algorithme dans Knuth ed. 3, p. 232; voir Wikipedia
  # http://en.wikipedia.org/wiki/Algorithms_for_calculating_variance#cite_note-1
  t.nobs += 1
  t.sumValue += x
  t.sumSquares += x*x
  delta = x - t.currentAverage
  t.currentAverage += delta/t.nobs
  t.currentSum2 += delta*(x-t.currentAverage)
  return t

end

function average(t::Tally)

    if (t.nobs < 1)
        return NaN
    else
        return t.currentAverage
    end

end

function nobs(t::Tally)

    return t.nobs

end

function sum(t::Tally)

    return t.sumValue

end

function variance(t::Tally)

    if (t.nobs < 2)
        return NaN
    else
        return t.currentSum2 / (t.nobs-1)
    end

end

function stdev(t::Tally)

    return sqrt(variance(t))

end

#    function tallyReport( this :: tally )
#        print("Report on Tally")
#        if (this.text != "") 
#            println(" : ",string(this.text))
#        end
#          println(" Number of observations: ",string(this.nobs))
#          println(" Minimum: ",string(round(this.minValue,3)),"\tMaximum: ",string(round(this.maxValue,3)))
          
#          tallyAverage = this.nobs > 0 ? this.currentAverage : NaN
#          tallyVariance = this.nobs > 1 ? this.currentSum2/(this.nobs - 1) : NaN
#          tallyStdv = this.nobs > 1 ? sqrt(tallyVariance) : NaN
#          println(" Average: ",string(round(tallyAverage,3)),"\tStandard deviation: ",string(round(tallyStdv,3)))
#    end

#    function resetTally(this::tally)  
 
#      this.text = ""
#      this.nobs = 0
#      this.minValue = Inf
#      this.maxValue = -Inf
#      this.sumValue = 0.0
#      this.sumSquares = 0.0
#      this.currentSum2 = 0.0
#      this.currentAverage = 0.0
      
#      return this

#    end

#end