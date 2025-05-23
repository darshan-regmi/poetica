/* This TypeScript code snippet defines interfaces `Quote` and `Poem` along with arrays `quotes` and
`poems` containing quote and poem objects respectively. The `Quote` interface specifies the
structure of a quote object with `id`, `text`, and `author` properties. The `Poem` interface
specifies the structure of a poem object with `id`, `title`, `content`, `author`, and `date`
properties. */
export interface Quote {
  id: string;
  text: string;
  author: string;
}

export interface Poem {
  id: string;
  title: string;
  content: string;
  author: string;
  date: string;
}

export const quotes: Quote[] = [
  {
    id: '1',
    text: 'Hope is the thing with feathers that perches in the soul and sings the tune without the words and never stops at all.',
    author: 'Emily Dickinson'
  },
  {
    id: '2',
    text: 'Two roads diverged in a wood, and I— I took the one less traveled by, and that has made all the difference.',
    author: 'Robert Frost'
  },
  {
    id: '3',
    text: 'The poetry of the earth is never dead.',
    author: 'John Keats'
  },
  {
    id: '4',
    text: 'Hold fast to dreams, for if dreams die, life is a broken-winged bird that cannot fly.',
    author: 'Langston Hughes'
  },
  {
    id: '5',
    text: 'In three words I can sum up everything I\'ve learned about life: it goes on.',
    author: 'Robert Frost'
  },
  {
    id: '6',
    text: 'We love the things we love for what they are.',
    author: 'Robert Frost'
  },
  {
    id: '7',
    text: 'Poetry is the spontaneous overflow of powerful feelings: it takes its origin from emotion recollected in tranquility.',
    author: 'William Wordsworth'
  }
];

export const poems: Poem[] = [
  {
    id: '1',
    title: 'Whispers of Dawn',
    content: 'Morning light filters through\nLeaves dancing in the breeze\nA new day begins.',
    author: 'Anonymous',
    date: '2025-05-01'
  },
  {
    id: '2',
    title: 'Ocean Dreams',
    content: 'Waves crash on distant shores\nCarrying memories of yesterday\nWashing away footprints\nLeaving only echoes.',
    author: 'Anonymous',
    date: '2025-04-15'
  }
];

export const getRandomQuote = (): Quote => {
  const randomIndex = Math.floor(Math.random() * quotes.length);
  return quotes[randomIndex];
};
