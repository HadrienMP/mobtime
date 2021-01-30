import express, {Request, Response} from 'express';
import logger from "morgan";
import favicon from 'serve-favicon';
import * as sse from './infra/sse';
import * as path from "path";
import * as bus from "./infra/bus"
import * as mobbers from "./mobbers/controller";
import * as stats from "./stats";
import * as mob from "./mob-controller";

const app = express();

app.set('views', path.join(__dirname, '../../views'));
app.set('view engine', 'pug');

// @ts-ignore
app.use(logger('dev'));
app.use(express.urlencoded({extended: false}));
app.use(express.static(path.join(__dirname, '../../public')));
app.use(favicon(path.join(__dirname, '../../public', 'images', 'favicon.png')));
app.use(express.json());

bus.init();

/* #####################################
    Routes
 #################################### */

app.get     ('/',       (req: Request, res: Response) => { res.render('index'); });

app.get     ('/mob/:name',                  mob.urlJoin);
app.get     ("/sse",                        sse.init);

app.get     ('/api/stats',                  stats.calculate);
app.post    ('/api/mob/',                   mob.apiJoin);
app.post    ("/api/mob/:mob/mobber",        mobbers.add);
app.put     ("/api/mob/:mob/mobber",        mobbers.update);
app.delete  ("/api/mob/:mob/mobber/:id",    mobbers.leave);

app.post    ('/api/mob/:mob/turn/start', (req: Request, res: Response) => {
    res.status(200).end();
});

// #####################################

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is listening on port ${PORT}`);
});