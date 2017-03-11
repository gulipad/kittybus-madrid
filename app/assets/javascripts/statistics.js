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
                console.log(request_count_array)
                processRequestTimeData(request_count_array)
                window.dispatchEvent(new Event('resize'));
                break;
            default:
                return
        }
        


    })

    $('#user-count-chart-select').on('change', function () {
        var select = $('#user-count-chart-select').val()
        console.log(select)
        $.post( "./stats", { value: select} )
            .then(function (response) {
                console.log(response.graph_data)
                processUserTimeData(response.graph_data)
                
            }, function (reject) {
                console.error(reject)
            })

    })

    $('#request-count-chart-select').on('change', function () {
        var select = $('#request-count-chart-select').val()
        console.log(select)
        $.post( "./stats", { value: select} )
            .then(function (response) {
                console.log(response.graph_data)
                processRequestTimeData(response.graph_data)
                
            }, function (reject) {
                console.error(reject)
            })

    })
})

function processUserTimeData (users_count_array) {
    var users = []
    var months = []
    return users_count_array.forEach(function (month) {
        users.push(month.users)
        months.push(month.month)

        $(function () { 
            var myChart = Highcharts.chart('user-time-graph', {
                chart: {
                    type: 'line'
                },
                title: {
                    text: 'User Growth in the Past ' + months.length + ' Months'
                },
                xAxis: {
                    title: {
                        text: 'Month'
                    },
                    categories: months
                },
                yAxis: {
                    title: {
                        text: 'Users'
                    }
                },
                series: [{
                    name: 'Users',
                    data: users
                }]
            })
        })
    })
}

function processRequestTimeData (request_count_array) {
    var requests = []
    var months = []
    return request_count_array.forEach(function (month) {
        requests.push(month.requests)
        months.push(month.month)

        $(function () { 
            var myChart = Highcharts.chart('request-time-graph', {
                chart: {
                    type: 'line'
                },
                title: {
                    text: 'Bus Request Growth in the Past ' + months.length + ' Months'
                },
                xAxis: {
                    title: {
                        text: 'Month'
                    },
                    categories: months
                },
                yAxis: {
                    title: {
                        text: 'Requests'
                    }
                },
                series: [{
                    name: 'Requests',
                    data: requests
                }]
            })
        })
    })
}

function hideAllOthers (graph) {
    var all = ['#user-time', '#request-time']
    console.log(all)
    console.log(graph)
    remove(all, graph)
    console.log(all)
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