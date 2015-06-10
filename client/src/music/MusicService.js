(function() {
    'use strict';

    angular
        .module('music')
        .factory('MusicService', MusicService);

    function MusicService($http) {
        var baseUrl = '/';

        return {
            getPopularFrom: getPopularFrom,
            getProductiveFrom: getProductiveFrom
        };

        function getPopularFrom(ago) {
            var url = baseUrl + 'music/' + ago + '/popular';

            return $http.get(url);
        }

        function getProductiveFrom(ago) {
            var url = baseUrl + 'music/' + ago + '/productive';

            return $http.get(url);
        }
    }
})();