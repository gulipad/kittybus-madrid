$(document).ready(function () {
    $('.main-container').biutifulGradient({color1: '#2af598',color2: '#009efd',angleDeg: '180'})

    $('a[href^="#"]').on('click', function(event) {
      var target = $(this.getAttribute('href'));
      if( target.length ) {
          event.preventDefault();
          $('html, body').stop().animate({
              scrollTop: target.offset().top
          }, 700);
      }
     });

    $('#graph-selector-select').on('change', function () {
        switch($('#graph-selector-select').val()) {
            case "1":
                break;
            case "2":
                hideAllOthers('#user-time')
                $('#user-time').addClass('user-time')
                $('#user-time').removeClass('hide')
                $('.graph-selector__modifier-text').css('font-size', '17px')
                $('#graph-selector-select').css('font-size', '17px')
                var users_count_array = ($('#users').data().users)
                processUserTimeData(users_count_array)
                window.dispatchEvent(new Event('resize'));
                break;
            case "3":
                hideAllOthers('#request-time')
                $('#request-time').addClass('request-time')
                $('#request-time').removeClass('hide')
                $('.graph-selector__modifier-text').css('font-size', '17px')
                $('#graph-selector-select').css('font-size', '17px')
                var request_count_array = ($('#requests').data().requests)
                processRequestTimeData(request_count_array)
                window.dispatchEvent(new Event('resize'));
                break;
            case "4":
                hideAllOthers('#bus-stop-analysis')
                var allStops = ($('#stops').data().stops)
                $( "#autocomplete-stops" ).autocomplete({ 
                    source: allStops.sort(),
                    select: function (e, ui) {
                        var stopId = ui.item.value
                        $.post( "./stats/stop-analysis", { value: stopId} )
                            .then(function (response) {
                                processStopAnalysis(response.graph_data)
                            }, function (reject) {
                                console.error(reject)
                            })
                    }
                });
                $.ui.autocomplete.filter = function (array, term) {
                   var matcher = new RegExp("^" + $.ui.autocomplete.escapeRegex(term), "i");
                   return $.grep(array, function (value) {
                       return matcher.test(value.label || value.value || value);
                   });
               };

                $('#bus-stop-analysis').addClass('bus-stop-analysis')
                $('#bus-stop-analysis').removeClass('hide')
                $('.bus-stop-analysis__modifier-text').css('font-size', '17px')
                $('#graph-selector-select').css('font-size', '17px')
                window.dispatchEvent(new Event('resize'));
                break;
            default:
                return
        }
    })

    $('#user-count-chart-select').on('change', function () {
        var select = $('#user-count-chart-select').val()
        $.post( "./stats/user", { value: select} )
            .then(function (response) {
                processUserTimeData(response.graph_data)
                
            }, function (reject) {
                console.error(reject)
            })

    })

    $('#request-count-chart-select').on('change', function () {
        var select = $('#request-count-chart-select').val()
        $.post( "./stats/request", { value: select} )
            .then(function (response) {
                processRequestTimeData(response.graph_data)
                
            }, function (reject) {
                console.error(reject)
            })

    })
})

function processUserTimeData (users_count_array) {
    var data = []
    users_count_array.forEach(function (day) {
        var date = new Date(day.date)
        data.push([Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate(), date.getUTCHours(), date.getUTCMinutes(), date.getUTCSeconds()), day.value])
    })

    $(function () { 
        var myChart = Highcharts.chart('user-time-graph', {
            chart: {
                type: 'area'
            },
            title: {
                text: 'User Growth in the Past ' + (data.length / 30) + ' Months'
            },
            xAxis: {
                type: 'datetime',
                dateTimeLabelFormats: {
                    month: '%b',
                    year: '%b'
                },
                title: {
                    text: 'Date'
                }
            },
            yAxis: {
                title: {
                    text: 'Users'
                }
            },
            series: [{
                name: 'Users',
                data: data
            }]
        })
    })
    
}

function processRequestTimeData (request_count_array) {
    var data = []
    request_count_array.forEach(function (day) {
        var date = new Date(day.date)
        data.push([Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate(), date.getUTCHours(), date.getUTCMinutes(), date.getUTCSeconds()), day.value])
    })

    $(function () { 
        var myChart = Highcharts.chart('request-time-graph', {
            chart: {
                type: 'area'
            },
            title: {
                text: 'Bus Request Growth in the Past ' + (data.length / 30) + ' Months'
            },
            xAxis: {
               type: 'datetime',
               dateTimeLabelFormats: {
                   month: '%b',
                   year: '%b'
               },
               title: {
                   text: 'Date'
               }
            },
            yAxis: {
                title: {
                    text: 'Requests'
                }
            },
            colors: ['#2af598'],
            series: [{
                name: 'Requests',
                data: data
            }]
        })
    })
}

function processStopAnalysis (stopData) {
    console.log(stopData.data, stopData.categories)
    $(function () { 
        var myChart = Highcharts.chart('bust-stop-analysis-graph', {
            chart: {
                    type: 'bar'
                },

                xAxis: {
                    categories: stopData.categories
                },

                series: [{
                    name: 'Requests',
                    data: stopData.data
                }]
        })
    })
}

function hideAllOthers (graph) {
    var all = ['#user-time', '#request-time', '#bus-stop-analysis']
    remove(all, graph)
    all.forEach(function (plot) {
        $(plot).removeClass(plot.replace('#', ''))
        $(plot).addClass('hide')
    })

}

function remove(arr, item) {
    for(var i = arr.length; i--;) {
        if(arr[i] === item) {
            arr.splice(i, 1);
        }
    }
}
