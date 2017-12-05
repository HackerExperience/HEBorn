module.exports = ({ file, options, env }) => ({
  plugins: {
    'autoprefixer': { browsers: ['last 2 versions'] },
  }
})
