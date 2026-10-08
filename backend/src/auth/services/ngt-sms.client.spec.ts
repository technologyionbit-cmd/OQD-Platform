import { sendNgtSms, toNgtMobileNumber } from './ngt-sms.client';

const CFG = {
  baseUrl: 'https://sms.test/send',
  loginName: 'aqd',
  loginPassword: 'secret',
  senderId: 'Aqd',
};

describe('toNgtMobileNumber', () => {
  it.each([
    ['+962791234567', '962791234567'],
    ['0791234567', '962791234567'],
    ['00962791234567', '962791234567'],
  ])('%p -> %p', (phone, expected) => {
    expect(toNgtMobileNumber(phone)).toBe(expected);
  });
});

describe('sendNgtSms', () => {
  const fetchMock = jest.fn<Promise<Response>, [URL, RequestInit?]>();
  const realFetch = global.fetch;

  beforeEach(() => {
    fetchMock.mockReset();
    global.fetch = fetchMock as unknown as typeof fetch;
  });
  afterAll(() => {
    global.fetch = realFetch;
  });

  const answer = (body: string) =>
    fetchMock.mockResolvedValueOnce(new Response(body));

  it('sends the gateway parameters and reads an I0x answer as success', async () => {
    answer('I01-Message sent');

    const result = await sendNgtSms(CFG, '+962791234567', 'code 123456');

    expect(result).toEqual({ ok: true, code: 'I01' });
    const url = fetchMock.mock.calls[0][0];
    expect(url.origin + url.pathname).toBe(CFG.baseUrl);
    expect(Object.fromEntries(url.searchParams)).toMatchObject({
      login_name: 'aqd',
      login_password: 'secret',
      msg: 'code 123456',
      mobile_number: '962791234567',
      from: 'Aqd',
      charset: 'UTF-8',
    });
  });

  it('reads an E0x answer as failure without the message text', async () => {
    answer('E05-Invalid sender');

    expect(await sendNgtSms(CFG, '+962791234567', 'code 123456')).toEqual({
      ok: false,
      code: 'E05',
    });
  });

  it('reads a JSON status answer', async () => {
    answer('{"status":"SUCCESS"}');

    expect(await sendNgtSms(CFG, '+962791234567', 'x')).toEqual({
      ok: true,
      code: 'SUCCESS',
    });
  });
});
