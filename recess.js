// Generated by CoffeeScript 2.1.1
use('recess-uglify');

tasks({
  js: [
    {
      entry: ['lib/**/*.js']
    },
    min,
    {
      outDir: 'out'
    }
  ]
});
